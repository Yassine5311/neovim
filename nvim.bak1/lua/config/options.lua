-- ── General Options ──────────────────────────────────────
-- Inspired by LazyVim, AstroNvim, NvChad
local opt = vim.opt
local g = vim.g

-- Leader key
g.mapleader = " "
g.maplocalleader = "\\"

-- Line numbers
opt.number = true
opt.relativenumber = true
opt.numberwidth = 2
opt.ruler = false
opt.signcolumn = "yes"
opt.cursorline = true
opt.cursorlineopt = "number" -- NvChad style: highlight only the line number

-- Tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.copyindent = true       -- AstroNvim: copy previous indentation on autoindenting
opt.preserveindent = true   -- AstroNvim: preserve indent structure as much as possible
opt.breakindent = true
opt.shiftround = true       -- LazyVim: round indent to shiftwidth

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.infercase = true         -- AstroNvim: infer cases in keyword completion
opt.inccommand = "nosplit"   -- LazyVim: preview incremental substitute
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.pumheight = 10
opt.pumblend = 10
opt.winblend = 10
opt.showmode = false
opt.laststatus = 3           -- global statusline
opt.cmdheight = 0            -- AstroNvim: hide command line unless needed
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.fillchars = { eob = " ", diff = "╱" }
opt.smoothscroll = true      -- LazyVim: smooth scrolling
opt.conceallevel = 2         -- LazyVim: hide markup for bold/italic
opt.title = true             -- AstroNvim: set terminal title

-- Behavior
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"     -- NvChad/LazyVim: stable splits on resize
opt.undofile = true
opt.undolevels = 10000
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.updatetime = 200
opt.timeoutlen = 300         -- LazyVim: faster which-key trigger
opt.completeopt = "menu,menuone,noselect"
opt.confirm = true
opt.wrap = false
opt.linebreak = true
opt.virtualedit = "block"    -- LazyVim: allow cursor past EOL in visual block
opt.whichwrap:append("<>[]hl")
opt.wildmode = "longest:full,full" -- LazyVim: better wildmenu completion
opt.winminwidth = 5          -- LazyVim: minimum window width
opt.jumpoptions = "view"     -- LazyVim: restore view on jump
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.formatoptions = "jcroqlnt" -- LazyVim: better format options

-- Shortmess (reduce messages)
opt.shortmess:append({ W = true, I = true, c = true, C = true, s = true })

-- Folding (treesitter-based)
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldtext = "" -- LazyVim: cleaner fold display

-- Fix markdown indentation settings
g.markdown_recommended_style = 0

-- Disable providers
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.loaded_node_provider = 0
