return {
    "mason-org/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        require("mason").setup()

        -- Get the ensure_installed list from lspconfig
        local ensure_installed = {}
        local lspconfig_spec = require("plugins.lspconfig")
        if lspconfig_spec.config then
            -- We need to extract the servers list, but it's in the config function
            -- So we'll define it here based on your lspconfig.lua
            ensure_installed = {
                "ts_ls",
                "rust_analyzer",
                "clangd",
                "pyright",  -- This is what you want, not pylsp
                "bashls",
                "astro",
                "html",
                "cssls",
                "jsonls",
                "lua_ls",
                "texlab",
            }
        end

        require("mason-lspconfig").setup({
            ensure_installed = ensure_installed,
            automatic_installation = true,
        })
    end,
}
