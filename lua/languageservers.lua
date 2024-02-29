local M = {}
		local servers = {
				"clangd",
                "omnisharp",
                "tsserver",
                "pylsp",
                "lua-language-server",
            }


function M.config()

    -- C++

    local lspconfig = require("lspconfig")
    lspconfig.lua_ls.setup{}

    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    for _, lsp in ipairs(servers) do
            lspconfig[lsp].setup({
                    on_attach = overrideattach,
                    capabilities = capabilities,
            })
    end

    -- C#

    local pid = vim.fn.getpid()
    local omnisharp_bin = "omnisharp"
    lspconfig.omnisharp.setup({
        handlers = {
            ["textDocument/definition"] = require("omnisharp_extended").handler,
        },
        cmd = { omnisharp_bin, "--languageserver", "--hostPID", tostring(pid) },

        on_attach = overrideattach,
        capabilities = capabilities,
    })

    -- CSS

    --lspconfig.tailwindcss.setup {
    --  on_attach = on_attach,
    --  capabilities = capabilities
    --}
end

return M
