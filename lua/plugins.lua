return require('packer').startup(function(use)
  -- Packer can manage itself
	    
        use 'wbthomason/packer.nvim'

	    use 'andweeb/presence.nvim'

        use("Hoffs/omnisharp-extended-lsp.nvim") -- Omnisharp extensions

        use({ 
            'dcampos/nvim-snippy',
            config = function() require("snippy").setup({
                mappings = {
                    is = {
                        ['<Tab>'] = 'expand_or_advance',
                        ['<S-Tab>'] = 'previous', },
                    nx = {
                        ['<leader>x'] = 'cut_text',
                    },
                },
            }) end,
        })

        use {
            "SmiteshP/nvim-navic",
            requires = "neovim/nvim-lspconfig"
        }
            
        use({
            "nvim-lualine/lualine.nvim", -- Statusline
            config = function() require("lualine-config").config() end,
        })
        
        use 'dcampos/cmp-snippy'

        use({
            "norcalli/nvim-colorizer.lua", -- Highlight colors
            config = function() require("colorizer").setup() end,
        })			
	    
        use({
            "nvimdev/template.nvim",
            config = function() require("template").setup({ temp_dir = '~/.config/nvim/templates' }) end,
	})

        use({
			"hrsh7th/nvim-cmp",
			config = function() require("cmp-config").config() end,
			requires = {
				"L3MON4D3/LuaSnip",
				"saadparwaiz1/cmp_luasnip",
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-path",
				"hrsh7th/cmp-nvim-lua",
				"onsails/lspkind.nvim",
			},
		})
		use({
            "williamboman/mason.nvim", -- Package manager for tools
				config = function()
				require("mason").setup()
				require("mason-lspconfig").setup()
            end,
            requires = { "williamboman/mason-lspconfig.nvim" },
        })
        use({
            "neovim/nvim-lspconfig", -- LSP Config
            config = function() require("languageservers").config() end,
        })

        use({
            "catppuccin/nvim", -- Catppuccin colorscheme
            config = function() require("catppuccin-config").config() end,
            as = "catppuccin",
            run = ":CatppuccinCompile",
        })
        
        use({
            "nvim-tree/nvim-tree.lua", -- Filetree
            config = function() require("nvim-tree-config").config() end,
            requires = { "nvim-tree/nvim-web-devicons" }, -- Icons
        })
end)
