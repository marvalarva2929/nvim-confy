local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])

vim.opt.rtp:prepend(lazypath)
vim.opt.tabstop = 4
vim.opt.shiftwidth=4
-- Define diagnostic signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
    signs = true,
    underline = true,
    virtual_text = {
        spacing = 4,
        prefix = '●',
        severity = { min = vim.diagnostic.severity.HINT },  -- Show all diagnostics
    },
    float = {
        border = "single",
        source = "always",  -- Show source of diagnostic
        header = "",
        prefix = "",
    },
    severity_sort = true,
})

-- Show diagnostics in a floating window when cursor holds on a line with errors
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        local opts = {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = 'single',
            source = 'always',
            prefix = ' ',
            scope = 'cursor',
        }
        vim.diagnostic.open_float(nil, opts)
    end
})

-- Decrease update time for CursorHold (default is 4000ms)
vim.opt.updatetime = 500

-- Allow backspace to delete characters in insert mode
vim.opt.backspace = {'indent', 'eol', 'start'}
-- Allow cursor to move one character past end of line in insert mode
vim.opt.virtualedit = 'onemore'

--@type LazySpec
local plugins = 'plugins'

-- Configure plugins.
require('lazy').setup(plugins)
require('commands')
require('hologram').setup{
    auto_display = true -- WIP automatic markdown image display, may be prone to breaking
}

-- Ctrl-Backspace to delete previous word in insert mode
vim.keymap.set('i', '<C-BS>', '<C-w>', { noremap = true, silent = true })
vim.keymap.set('i', '<C-H>', '<C-w>', { noremap = true, silent = true }) -- Fallback for terminals that send Ctrl-H for Ctrl-Backspace

-- Window navigation without Ctrl-w
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })

vim.opt.number = true;
