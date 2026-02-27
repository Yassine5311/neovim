# Neovim Config

A fast, modern Neovim setup built around lazy.nvim with LSP, completion, Git tooling, and UI polish.

## Features
- Lazy-loaded plugin system
- LSP + diagnostics with Mason and lspconfig
- Completion with nvim-cmp, LuaSnip, Copilot
- Treesitter syntax highlighting
- Git workflow with gitsigns, diffview, neogit
- UI extras: lualine, bufferline, dashboard, which-key, dropbar, scrollbar
- Matugen auto-theming via base16

## Requirements
- Neovim 0.11+
- Git
- Node.js (for Copilot and some tools)
- Ripgrep (telescope live grep)
- Nerd Font (recommended for icons)

## Install
1. Clone this repo into ~/.config/nvim
2. Start Neovim: lazy.nvim will install plugins automatically

## Key Highlights
- <leader>ff: find files
- <leader>fg: live grep
- <leader>gd: diffview
- <leader>gG: neogit
- <leader>aa: Copilot Chat
- <leader>cf: format
- <leader>xx: diagnostics (Trouble)

## Matugen Auto Theme
- matugen-template.lua is the template
- matugen.lua is generated and auto-reloaded when updated

## Notes
- Run :Copilot auth on first use
- Run :TSUpdate if treesitter parsers are missing
