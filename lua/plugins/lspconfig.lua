return {
    "neovim/nvim-lspconfig", -- LSP Config
    requires = {
        "folke/neoconf.nvim", -- Lua lsp config manager
        "hrsh7th/nvim-cmp",
        "nvimtools/none-ls.nvim", -- Linter management
        "nvimtools/none-ls-extras.nvim",
        "seblj/roslyn.nvim", -- Make roslyn-lsp not broken
        "Bilal2453/luvit-meta", -- vim.uv typings
        "williamboman/mason.nvim",
    },
    config = function()
        local lspconfig = require("lspconfig")
		local client_capabilities = require("lsp").client_capabilities
        local function setup_lspconfig(name, config)
            vim.lsp.enable(name)
            vim.lsp.config(
                name,
                vim.tbl_deep_extend("force", {
                    capabilities = client_capabilities(),
                }, config or {})
            )
        end

        local servers = {
            { "ts_ls" },
			{ "jdtls" },
            {
                "rust_analyzer",
                {
                    settings = {
                        ["rust-analyzer"] = {
                            diagnostics = {
                                disabled = {
                                    "needless_return",
                                    "unlinked-file",
                                },
                            },
                        },
                    },
                },
            },
            { "clangd" },
            { "pyright" },
            { "bashls" },
            { "astro" },
            { "html" },
            { "cssls" },
            { "jsonls" },
            {
                "lua_ls",
                {
                    root_markers = { { "selene.toml", "stylua.toml" }, ".git" },
                    settings = {
                        Lua = {
                            runtime = {
                                version = "LuaJit",
                            },
                            completion = {
                                callSnippet = "Replace",
                            },
                            diagnostics = {
                                globals = {
                                    "vim",
                                },
                            },
                        },
                    },
                },
            },
            { "msbuild_project_tools_server", nil, true },
            -- { "nginx_language_server" },
            { "texlab" },
            { "gdscript", nil, true },
        }

	   for _, server in ipairs(servers) do
            setup_lspconfig(server[1], server[2])
        end

        local ensure = {}
        for _, server in ipairs(servers) do
            if not server[3] then
                table.insert(ensure, server[1])
            end
        end
    end,
}
