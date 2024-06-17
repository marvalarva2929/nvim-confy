local M = {}

function M.config()
    local cfg = {

        transparent_background = true,-- disables setting the background color.

        compile = {
            enabled = true,
        },
        integrations = {
            --treesitter = true,
        },
        dim_inactive = {
            enabled = true,
            shade = "dark",
            percentage = 1,
        },

        custom_highlights = function(colors)
            local identifier = { fg = colors.mauve, style = { "italic" } }
            return {
                -- Treesitter / Semantic tokens
                ["@keyword"] = identifier,
                ["@keyword.function"] = identifier,
                ["@keyword.return"] = identifier,
                ["@keyword.operator"] = identifier,
                ["@constant.builtin"] = identifier,
                ["@type.builtin"] = identifier,
                ["@type.qualifier"] = identifier,
                ["@storageclass"] = identifier,
                ["@boolean"] = identifier,
                ["@operator"] = identifier,
                ["@include"] = identifier,
                ["@repeat"] = identifier,
                ["@method"] = { fg = colors.blue },
                ["@method.call"] = { fg = colors.blue },
                ["@event_name"] = { fg = colors.blue },
                ["@lsp.type.delegate_name.cs"] = { fg = colors.blue },
                ["@character"] = { fg = colors.green },
                ["@namespace"] = { fg = colors.yellow, style = {} },
                ["@constructor"] = { fg = colors.yellow },
                ["@lsp.type.class_name.cs"] = { fg = colors.yellow },
                ["@lsp.type.struct_name.cs"] = { fg = colors.yellow },
                ["@lsp.type.interface_name.cs"] = { fg = colors.yellow },
                ["@class_name"] = { fg = colors.yellow },
                ["@variable"] = { fg = colors.teal },
                ["@label"] = { fg = colors.teal },
                ["@label.json"] = { fg = colors.teal },
                ["@punctuation"] = { fg = colors.overlay2 },
                ["@field_name"] = { fg = colors.lavender },
                ["@local_name"] = { fg = colors.teal },
                -- Solution Explorer
                ["SolutionExplorerSolution"] = { fg = colors.mauve },
                ["SolutionExplorerProject"] = { fg = colors.green },
                ["SolutionExplorerFolder"] = { fg = colors.blue },
                ["SolutionNugetHeader"] = { fg = colors.base, bg = colors.peach, style = { "bold" } },
                ["SolutionNugetHighlight"] = { fg = colors.sky },
            }
        end,
    }
    
    vim.g.catppuccin_flavour = "macchiato"
    require("catppuccin").setup(cfg)

    vim.cmd([[colorscheme catppuccin]])
end

return M
