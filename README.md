# Neovim Configuration

A performance-oriented and modular Neovim configuration built on lazy.nvim, featuring modern LSP integration, intelligent completion, Git tooling, and a polished UI.

## Overview

This setup is designed for:

- Fast startup through lazy-loading
- Minimal boilerplate with maximal extensibility
- Clean UI with practical developer ergonomics
- Fully managed LSP and tooling via Mason

## Core Features

### Plugin Management

- Lazy-loaded architecture powered by lazy.nvim

### LSP and Tooling

- LSP configuration via nvim-lspconfig
- External tool management via mason.nvim
- Diagnostics integration with trouble.nvim

### Autocompletion

- Completion engine: nvim-cmp
- Snippets: LuaSnip
- AI assistance: GitHub Copilot

### Syntax Highlighting

- Incremental parsing via nvim-treesitter

### Git Integration

- Inline Git indicators: gitsigns.nvim
- Diff viewer: diffview.nvim
- Git UI: neogit

### UI Enhancements

- Statusline: lualine.nvim
- Bufferline: bufferline.nvim
- Dashboard: dashboard-nvim
- Keybinding hints: which-key.nvim
- Breadcrumbs: dropbar.nvim
- Scrollbar UI: nvim-scrollbar

### Theming

- Base16 theming with automatic color generation via Matugen

## Requirements

Ensure the following dependencies are installed:

- Neovim 0.11+
- Git
- Node.js (required for Copilot, CopilotChat, and some LSP servers)
- Ripgrep (required for Telescope live grep)
- fd (recommended for faster file search)
- make (required for native extensions like telescope-fzf-native and CopilotChat)
- A C compiler (required by nvim-treesitter)
- tree-sitter-cli (required for some Treesitter installs)
- Yarn or npm (required for markdown-preview.nvim build)
- Nerd Font (recommended for proper icon rendering)
- lazygit (optional, used by Snacks integration)

## Installation

```sh
git clone https://github.com/Yassine5311/neovim.git ~/.config/nvim
```

Then launch:

```sh
nvim
```

On first run, lazy.nvim will automatically install all plugins.

## Key Mappings (Highlights)

| Keybinding | Action |
| --- | --- |
| <leader>ff | Find files |
| <leader>fg | Live grep |
| <leader>gd | Open Diffview |
| <leader>gG | Open Neogit |
| <leader>aa | Copilot Chat |
| <leader>cf | Format buffer |
| <leader>xx | Show diagnostics (Trouble) |

## Matugen Auto-Theming

- matugen-template.lua -> Theme template
- matugen.lua -> Auto-generated file
- Automatically reloads when updated

## Post-Install Notes

- Run :Copilot auth on first use to authenticate.
- Run :TSUpdate if Treesitter parsers are missing.
- Use :Mason to manage external LSP servers and formatters.
