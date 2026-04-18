<div align="center">
  <h1>⚡ ZERO's Neovim</h1>
  <p>A blazingly fast, modern Neovim 0.12+ configuration built for 2026.</p>
  
  <img src="assets/dashboard.png" alt="Dashboard" style="border-radius: 8px; border: 1px solid #333; margin: 15px 0;">
  
  <p>
    <img src="https://img.shields.io/badge/Neovim-0.12+-blue.svg?style=for-the-badge&logo=neovim" alt="Neovim Version" />
    <img src="https://img.shields.io/badge/Package_Manager-lazy.nvim-blueviolet.svg?style=for-the-badge" alt="Lazy.nvim" />
    <img src="https://img.shields.io/badge/Completion-blink.cmp-FF9E0F.svg?style=for-the-badge" alt="Blink.cmp" />
  </p>
</div>

## ✨ Overview

This configuration is engineered for **ultimate performance** and **modularity**, keeping up with the 2026 development standards. Built on top of `lazy.nvim`, it provides a highly extensible base without the bloat, featuring an ultra-fast completion engine (`blink.cmp`), AI assistance, and seamless native LSP and formatting capabilities.

## 🚀 Features

- **⚡ Blazingly Fast Completion:** Powered by `blink.cmp` (integrated with `LuaSnip`), explicitly configured as the 2026 standard replacement for `nvim-cmp`.
- **🧠 AI Assistance:** Deep integration with GitHub Copilot (Inline Suggestions & Copilot Chat) for rapid development.
- **🛠️ Tooling & LSP:** Seamlessly managed via `mason.nvim` and native `nvim-lspconfig`, with formatting offloaded to the highly efficient `conform.nvim`.
- **🌲 Syntax & Parsing:** Incremental, precise syntax highlighting and code parsing via `nvim-treesitter`.
- **☕ Enterprise Java Support:** Robust J2EE/Servlet capabilities including JDTLS, Maven, JUnit, and remote Tomcat debugging. (See [JAVA_SETUP.md](./JAVA_SETUP.md)).
- **🎨 Immersive UI:** Features `lualine.nvim`, `bufferline.nvim`, `dashboard-nvim`, `noice.nvim`, and automated theming via **Matugen** (Base16).
- **🐙 Advanced Git Tooling:** Git line indicators (`gitsigns.nvim`), conflict/diff resolving (`diffview.nvim`), and a powerful TUI (`neogit`).

## ⚙️ Installation

We provide a robust, interactive installation script that naturally handles dependencies using your system's package manager (`apt`, `dnf`, `pacman`, `brew`).

### 1. Clone the configuration
```sh
git clone https://github.com/Yassine5311/neovim.git ~/.config/nvim
```

### 2. Run the interactive installer
```sh
cd ~/.config/nvim
./install.sh
```

> **Note:** The installer provides a menu allowing you to install core dependencies, optional enterprise languages (`Java`, `Python`, `Go`, `Rust`), and interactive tools like `Lazygit` and `Clipboard` integrations. After the native dependencies are configured, Neovim will launch headlessly to automatically bootstrap and sync all of your plugins.

## ⌨️ Key Mappings (Highlights)

| Keybinding | Action |
| :--- | :--- |
| `<leader>ff` | Find files (`Telescope`) |
| `<leader>fg` | Live grep (`Telescope`) |
| `<leader>gd` | Open `Diffview` |
| `<leader>gG` | Open `Neogit` |
| `<leader>aa` | Toggle `Copilot Chat` |
| `<leader>cf` | Format current buffer (`conform.nvim`) |
| `<leader>xx` | Toggle Workspace Diagnostics (`trouble.nvim`) |

## 🎨 Matugen Auto-Theming

The colorscheme is dynamically generated using Matugen for a customized experience.
- `matugen-template.lua` -> Theme template
- `matugen.lua` -> Auto-generated output file
- Colors automatically hot-reload when updated.

## 💡 Post-Install Notes

- **Copilot**: Run `:Copilot auth` on first use to authenticate with your GitHub account.
- **Treesitter**: Run `:TSUpdate` if any syntax highlighting appears incomplete or parsers are missing.
- **Tooling**: Run `:Mason` to visually browse, install, or update additional external LSP servers, linters, or formatters.
