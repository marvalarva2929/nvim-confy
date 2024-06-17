-- Bubbles config for lualine
-- Author: lokesh-krishna
-- MIT license, see LICENSE for more details.

-- stylua: ignore
local colors = {
  blue   = '#80a0ff',
  cyan   = '#79dac8',
  black  = '#080808',
  white  = '#c6c6c6',
  red    = '#ff5189',
  violet = '#d183e8',
  grey   = '#303030',
}

local bubbles_theme = {
  normal = {
    a = { fg = colors.black, bg = colors.violet },
    b = { fg = colors.white, bg = colors.grey },
    c = { fg = colors.white },
  },

  insert = { a = { fg = colors.black, bg = colors.blue } },
  visual = { a = { fg = colors.black, bg = colors.cyan } },
  replace = { a = { fg = colors.black, bg = colors.red } },

  inactive = {
    a = { fg = colors.white, bg = colors.black },
    b = { fg = colors.white, bg = colors.black },
    c = { fg = colors.white },
  },
}
return {
	'nvim-lualine/lualine.nvim',
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	require('lualine').setup {
	  options = {
	    theme = bubbles_theme,
	    component_separators = '',
	    section_separators = { left = '', right = '' },
	  },
	  sections = {
	    lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
	    lualine_b = { 'filename', 'branch' },
	    lualine_c = {
	      '%=', 'diagnostics'
	    },
	    lualine_x = {{
		function()
		    local msg = "No Active LSP"
		    local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
		    local clients = vim.lsp.get_active_clients()

		    if next(clients) == nil then
			return msg
		    end

		    local names = ""
		    for _, client in ipairs(clients) do
			local filetypes = client.config.filetypes
			if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 and client.name ~= "null-ls" then
			    names = names .. client.name .. " "
			end
		    end

		    if names ~= "" then
			return names:sub(1, -2)
		    end

		    return msg
		end,
		icon = " LSP:",
	    }},
	    lualine_y = { 'filetype', 'progress' },
	    lualine_z = {
	      { 'location', separator = { right = '' }, left_padding = 2 },
	    },
	  },
	  inactive_sections = {
	    lualine_a = { 'filename' },
	    lualine_b = {},
	    lualine_c = {},
	    lualine_x = {},
	    lualine_y = {},
	    lualine_z = { 'location' },
	  },
	  tabline = {},
	  extensions = {},
	}
}

