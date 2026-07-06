# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration written entirely in Lua, using **Lazy.nvim** as the plugin manager. The configuration follows a modular architecture with clear separation of concerns.

## Architecture

### Core Structure

```
init.lua              # Bootstrap Lazy.nvim and load plugins
lua/
├── settings.lua      # Editor settings (indentation, UI, clipboard, etc.)
├── keymaps.lua       # Global keybindings
├── autocmds.lua      # Autocommands organized by augroup
├── commands.lua      # Custom user commands
├── lsp.lua           # LSP utilities and configuration helpers
├── icons.lua         # Centralized Nerd Font icon library
├── winbar.lua        # Breadcrumb path display
├── lightbulb.lua     # Code action indicator
├── float_term.lua    # Floating terminal utility
└── plugins/          # Lazy.nvim plugin specs (one file per plugin)
```

### Plugin Management

Uses **Lazy.nvim** with modular plugin specs. Each file in `lua/plugins/` returns a Lazy.nvim spec table:

```lua
return {
    "author/plugin",
    dependencies = { "dep1", "dep2" },
    event = "BufEnter",           -- Lazy load trigger
    keys = { ... },                -- Keybinding definitions
    config = function(plugin, opts)
        require("plugin").setup(opts)
    end,
}
```

The init.lua bootstraps Lazy.nvim if not present and loads all plugins from the `plugins` directory.

### LSP Configuration Pattern

LSP servers are configured in `lua/plugins/lspconfig.lua` using Neovim's modern `vim.lsp.enable()` and `vim.lsp.config()` API (0.10+). The `servers` table defines all language servers with their specific settings.

**Currently configured servers:**
- TypeScript/JavaScript: `ts_ls`
- Rust: `rust_analyzer` (with specific diagnostics disabled)
- C/C++: `clangd`
- Python: `pylsp`
- Bash: `bashls`
- Astro: `astro`
- HTML: `html`
- CSS: `cssls`
- JSON: `jsonls`
- Lua: `lua_ls` (with LuaJIT runtime, vim global)
- .NET: `msbuild_project_tools_server` (optional)
- Go: `gopls` (with postfix completions, analyses enabled)
- LaTeX: `texlab`
- GDScript: `gdscript` (optional)

To add a new LSP server:
1. Add entry to `servers` table in `lspconfig.lua`: `{ "server_name", { settings }, optional_flag }`
2. Servers without `optional_flag` (3rd param) are automatically added to Mason's ensure_installed
3. Server-specific settings go in the 2nd table parameter

The `lsp.lua` module exports:
- `client_capabilities()`: Merges default LSP capabilities with nvim-cmp capabilities
- `open_float()`: Smart hover/diagnostic display with custom markdown styling

### Keybinding Conventions

- **Leader key**: Space (`<leader>`)
- **Namespaces**:
  - `<leader>a*` = AI/Claude operations
  - `<leader>x*` = Lists (quickfix, location list)
  - `<leader>t*` = Tab operations
  - `<leader>L` = Lazy.nvim package manager

### Autocommand Organization

Autocommands in `autocmds.lua` are organized by augroup with the `mariasolos/` prefix:
- `mariasolos/close_with_q`: Close special buffers with 'q'
- `mariasolos/dotfiles_setup`: Git worktree handling for dotfiles
- `mariasolos/last_location`: Resume at last edit position
- `mariasolos/toggle_line_numbers`: Switch between relative/absolute line numbers

When adding new autocommands, follow this pattern and group related autocmds under a descriptive augroup name.

### AI Integration

The config includes both GitHub Copilot and Claude Code:
- **Copilot**: Lazy-loaded on `InsertEnter` event
- **Claude Code**: Available via `:ClaudeCode` command with keybindings under `<leader>a*`

## Common Development Tasks

### Plugin Management

```bash
# Install/update plugins
nvim
:Lazy

# Sync lockfile
:Lazy sync

# Clean unused plugins
:Lazy clean
```

### LSP Management

The configuration uses Mason for automatic LSP server installation. Non-optional servers from the `servers` table in `lspconfig.lua` are automatically ensured.

### Adding a New Plugin

1. Create a new file in `lua/plugins/` (e.g., `lua/plugins/myplugin.lua`)
2. Return a Lazy.nvim spec table with plugin URL, dependencies, and config
3. Restart Neovim or `:Lazy reload`
4. Lazy.nvim will automatically detect and load the new spec

### Modifying Settings

- **Editor behavior**: Edit `lua/settings.lua`
- **Keybindings**: Edit `lua/keymaps.lua` for global mappings, or add to plugin spec's `keys` field for plugin-specific bindings
- **LSP settings**: Edit server configs in `lua/plugins/lspconfig.lua`

## Code Style

- **Indentation**: 4 spaces, `expandtab` enabled
- **Lua style**: Use `vim.opt`/`vim.o`/`vim.wo` for options, `vim.keymap.set()` for mappings
- **Module pattern**: Files that export utilities use `local M = {}` and `return M`
- **Lazy loading**: Prefer event-based (`event`), command-based (`cmd`), or keymap-based (`keys`) lazy loading for performance

## Important Notes

- The configuration disables Python3, Ruby, Perl, and Node providers for performance
- Diagnostic signs are disabled globally (configured in init.lua)
- The config uses Treesitter for folding (`foldmethod='expr'`, `foldexpr='v:lua.vim.treesitter.foldexpr()'`)
- Clipboard is synced with OS via `clipboard='unnamedplus'`
