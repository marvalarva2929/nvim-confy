-- Cursor-esque Claude workspace: side terminal + viewport tracking + status panel.

local M = {}

local CLAUDE_WIDTH_PCT = 0.38
local DEBOUNCE_MS      = 200
local RECENT_MAX       = 6
local STATUS_W         = 52
local STATUS_H         = RECENT_MAX + 3  -- header + separator + label + files

local st = {
    enabled      = false,
    content_win  = nil,   -- main editing window
    claude_win   = nil,   -- terminal window
    status_win   = nil,   -- floating notes panel
    status_buf   = nil,
    recent       = {},    -- recently modified paths, newest-first
    current_file = nil,   -- path currently shown due to Claude's edit
    augroup      = nil,
    fs_handle    = nil,   -- uv fs_event watcher
    timer        = nil,   -- debounce timer handle
    pending      = nil,   -- path awaiting debounce flush
}

-- ─── utilities ────────────────────────────────────────────────────────────────

local function win_ok(id) return id ~= nil and vim.api.nvim_win_is_valid(id) end
local function buf_ok(id) return id ~= nil and vim.api.nvim_buf_is_valid(id) end
local function short(p)   return vim.fn.fnamemodify(p, ':~:.') end

local IGNORE = {
    '[/\\]%.git[/\\]', '[/\\]%.git$',
    '[/\\]node_modules[/\\]', '[/\\]__pycache__[/\\]',
    '%.pyc$', '%.class$', '%.o$',
    'lazy%-lock%.json$',
    '%.swp$', '%.swo$', '4913$',
}

local function ignored(p)
    if not p or p == '' then return true end
    for _, pat in ipairs(IGNORE) do
        if p:match(pat) then return true end
    end
    return false
end

-- ─── status panel ─────────────────────────────────────────────────────────────

local hl_ns = vim.api.nvim_create_namespace('claude_workspace')

local function fit(s, max)
    return #s <= max and s or ('…' .. s:sub(-(max - 1)))
end

local function render()
    if not win_ok(st.status_win) or not buf_ok(st.status_buf) then return end

    vim.bo[st.status_buf].modifiable = true
    local w     = STATUS_W - 4
    local lines = {}

    if st.current_file then
        table.insert(lines, ' 󰏫  ' .. fit(short(st.current_file), w))
    else
        table.insert(lines, '    Watching for edits…')
    end
    table.insert(lines, ' ' .. string.rep('─', STATUS_W - 2))
    table.insert(lines, ' 󰋚  Recent:')

    if #st.recent == 0 then
        table.insert(lines, '     (none yet)')
    else
        for i = 1, math.min(#st.recent, RECENT_MAX) do
            table.insert(lines, '  󰈙  ' .. fit(short(st.recent[i]), w - 2))
        end
    end

    vim.api.nvim_buf_set_lines(st.status_buf, 0, -1, false, lines)
    vim.bo[st.status_buf].modifiable = false

    vim.api.nvim_buf_clear_namespace(st.status_buf, hl_ns, 0, -1)
    vim.api.nvim_buf_add_highlight(st.status_buf, hl_ns,
        st.current_file and 'DiagnosticOk' or 'Comment', 0, 0, -1)
    vim.api.nvim_buf_add_highlight(st.status_buf, hl_ns, 'NonText', 1, 0, -1)
    vim.api.nvim_buf_add_highlight(st.status_buf, hl_ns, 'Title',   2, 0, -1)
    for i = 3, #lines - 1 do
        vim.api.nvim_buf_add_highlight(st.status_buf, hl_ns, 'Comment', i, 0, -1)
    end
end

local function panel_open()
    if win_ok(st.status_win) then return end

    st.status_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[st.status_buf].buftype    = 'nofile'
    vim.bo[st.status_buf].bufhidden  = 'hide'
    vim.bo[st.status_buf].modifiable = false

    st.status_win = vim.api.nvim_open_win(st.status_buf, false, {
        relative  = 'editor',
        row       = vim.o.lines - STATUS_H - 3,
        col       = 1,
        width     = STATUS_W,
        height    = STATUS_H,
        style     = 'minimal',
        border    = 'rounded',
        title     = ' ✦ Claude Workspace ',
        title_pos = 'center',
        zindex    = 45,
        focusable = false,
    })
    vim.wo[st.status_win].winblend = 10
    render()
end

local function panel_close()
    if win_ok(st.status_win) then
        pcall(vim.api.nvim_win_close, st.status_win, true)
    end
    if buf_ok(st.status_buf) then
        pcall(vim.api.nvim_buf_delete, st.status_buf, { force = true })
    end
    st.status_win = nil
    st.status_buf = nil
end

-- ─── viewport switching ───────────────────────────────────────────────────────

local function find_content_win()
    if win_ok(st.content_win) then return st.content_win end
    for _, w in ipairs(vim.api.nvim_list_wins()) do
        if w ~= st.status_win and w ~= st.claude_win then
            local b = vim.api.nvim_win_get_buf(w)
            if vim.bo[b].buftype == '' then return w end
        end
    end
end

local function jump(path)
    local win = find_content_win()
    if not win then return end

    -- Don't hijack a window the user is actively writing in
    if win == vim.api.nvim_get_current_win() then
        local mode = vim.api.nvim_get_mode().mode
        local cur  = vim.api.nvim_win_get_buf(win)
        if mode == 'i' or mode == 't' or vim.bo[cur].modified then return end
    end

    local bufnr = vim.fn.bufnr(path)
    if bufnr == -1 then
        bufnr = vim.fn.bufadd(path)
        vim.fn.bufload(bufnr)
    end
    if bufnr > 0 and buf_ok(bufnr) then
        vim.api.nvim_win_set_buf(win, bufnr)
    end
end

-- ─── change handler ───────────────────────────────────────────────────────────

local function changed(path)
    if not st.enabled or ignored(path) then return end

    st.current_file = path

    local seen, fresh = { [path] = true }, { path }
    for _, f in ipairs(st.recent) do
        if not seen[f] then
            seen[f] = true
            table.insert(fresh, f)
            if #fresh >= RECENT_MAX then break end
        end
    end
    st.recent = fresh

    jump(path)
    render()
end

local function debounce(path)
    st.pending = path
    if st.timer then
        pcall(function() st.timer:stop(); st.timer:close() end)
    end
    st.timer = vim.defer_fn(function()
        local p  = st.pending
        st.pending = nil
        if p then changed(p) end
    end, DEBOUNCE_MS)
end

-- ─── watchers ─────────────────────────────────────────────────────────────────

local function watchers_start()
    local cwd = vim.fn.getcwd()

    local h = vim.uv.new_fs_event()
    if h then
        local cb = function(err, name, _)
            if not err and name then
                vim.schedule(function() debounce(cwd .. '/' .. name) end)
            end
        end
        local ok = pcall(function() h:start(cwd, { recursive = true }, cb) end)
        if ok then
            st.fs_handle = h
        else
            pcall(function() h:close() end)
        end
    end

    st.augroup = vim.api.nvim_create_augroup('ClaudeWorkspace', { clear = true })

    -- Catch external changes on already-loaded buffers (belt + suspenders)
    vim.api.nvim_create_autocmd('FileChangedShellPost', {
        group = st.augroup,
        callback = function(ev)
            local n = vim.api.nvim_buf_get_name(ev.buf)
            if n ~= '' then debounce(n) end
        end,
    })

    -- Keep content_win in sync when user navigates between windows
    vim.api.nvim_create_autocmd('WinEnter', {
        group = st.augroup,
        callback = function()
            local w = vim.api.nvim_get_current_win()
            local b = vim.api.nvim_win_get_buf(w)
            if w ~= st.status_win and w ~= st.claude_win
               and vim.bo[b].buftype == '' then
                st.content_win = w
            end
        end,
    })
end

local function watchers_stop()
    if st.fs_handle then
        pcall(function()
            if not st.fs_handle:is_closing() then
                st.fs_handle:stop()
                st.fs_handle:close()
            end
        end)
        st.fs_handle = nil
    end
    if st.augroup then
        pcall(vim.api.nvim_del_augroup_by_id, st.augroup)
        st.augroup = nil
    end
end

-- ─── Claude terminal ──────────────────────────────────────────────────────────

local function claude_open()
    if win_ok(st.claude_win) then
        vim.api.nvim_set_current_win(st.claude_win)
        vim.cmd('startinsert')
        return
    end

    st.content_win = vim.api.nvim_get_current_win()
    local width    = math.max(45, math.floor(vim.o.columns * CLAUDE_WIDTH_PCT))

    vim.cmd('botright ' .. width .. 'vsplit')
    vim.cmd('terminal claude')
    st.claude_win = vim.api.nvim_get_current_win()

    local tbuf = vim.api.nvim_win_get_buf(st.claude_win)
    vim.b[tbuf].is_claude_workspace = true
    pcall(vim.api.nvim_buf_set_name, tbuf, 'Claude[workspace]')

    vim.cmd('startinsert')

    -- Return focus to content after the terminal starts
    vim.schedule(function()
        if win_ok(st.content_win) then
            vim.api.nvim_set_current_win(st.content_win)
        end
    end)
end

local function claude_close()
    if not win_ok(st.claude_win) then
        st.claude_win = nil
        return
    end
    if vim.api.nvim_get_current_win() == st.claude_win then
        local cwin = find_content_win()
        if cwin then vim.api.nvim_set_current_win(cwin) end
    end
    pcall(vim.api.nvim_win_close, st.claude_win, true)
    st.claude_win = nil
end

-- ─── public ───────────────────────────────────────────────────────────────────

function M.open()
    if st.enabled then
        -- Re-focus Claude if already running
        if win_ok(st.claude_win) then
            vim.api.nvim_set_current_win(st.claude_win)
            vim.cmd('startinsert')
        end
        return
    end
    st.enabled = true
    claude_open()
    watchers_start()
    vim.schedule(panel_open)
end

function M.close()
    if not st.enabled then return end
    st.enabled = false
    watchers_stop()
    panel_close()
    claude_close()
    st.content_win = nil
    st.recent      = {}
    st.current_file = nil
end

function M.toggle()
    if st.enabled then M.close() else M.open() end
end

function M.setup() end

return M
