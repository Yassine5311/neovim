-- ── Autocommands ─────────────────────────────────────────
-- Inspired by LazyVim autocmds
local function augroup(name)
  return vim.api.nvim_create_augroup("zero_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed (LazyVim)
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight on yank (LazyVim)
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- Resize splits when window is resized (LazyVim)
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Restore cursor position (LazyVim)
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].zero_last_loc then
      return
    end
    vim.b[buf].zero_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close some filetypes with <q> (LazyVim)
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup", "checkhealth", "dbout", "gitsigns-blame",
    "grug-far", "help", "lspinfo", "neotest-output", "neotest-output-panel",
    "neotest-summary", "notify", "qf", "spectre_panel", "startuptime",
    "tsplayground", "lazy", "mason",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", {
      buffer = event.buf,
      silent = true,
      desc = "Close window",
    })
  end,
})

-- Make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- Wrap and spell check in text filetypes (LazyVim)
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Auto create dir when saving a file where dir doesn't exist (LazyVim)
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Go to last loc when opening a buffer (deduplication guard)
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = augroup("auto_hlsearch"),
  callback = function()
    -- Disable hlsearch when entering insert mode
    vim.on_key(function(char)
      if vim.fn.mode() == "n" then
        local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
        if vim.opt.hlsearch:get() ~= new_hlsearch then
          vim.opt.hlsearch = new_hlsearch
        end
      end
    end, vim.api.nvim_create_namespace("auto_hlsearch"))
  end,
  once = true,
})

-- ── Additional autocmds from popular configs ──

-- Fix conceallevel for json files (LazyVim)
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Auto reload tmux/kitty/wezterm configs on save (AstroNvim pattern)
vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup("config_reload"),
  pattern = { "*tmux.conf", "*/kitty/*.conf" },
  callback = function(event)
    local file = event.match
    if file:match("tmux") and vim.fn.executable("tmux") == 1 then
      vim.fn.system("tmux source-file " .. file)
      vim.notify("Tmux config reloaded", vim.log.levels.INFO)
    end
  end,
})

-- Auto toggle relative line numbers on focus/mode change (NvChad/common)
vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
  group = augroup("toggle_relnum"),
  callback = function(event)
    if vim.wo.number then
      vim.wo.relativenumber = event.event == "InsertLeave"
    end
  end,
})

-- Large file detection fallback (complement to snacks bigfile)
vim.api.nvim_create_autocmd("BufReadPre", {
  group = augroup("large_file"),
  callback = function(event)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(event.buf))
    if ok and stats and stats.size > 1024 * 1024 then -- 1MB
      vim.opt_local.swapfile = false
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.undolevels = -1
      vim.opt_local.undoreload = 0
      vim.opt_local.list = false
    end
  end,
})
