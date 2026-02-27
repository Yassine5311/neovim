-- ── File Explorer (nvim-tree) ────────────────────────────
-- Inspired by NvChad
return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
    keys = {
      { "<leader>ee", "<cmd>NvimTreeToggle<cr>",              desc = "Toggle file explorer" },
      { "<leader>ef", "<cmd>NvimTreeFindFileToggle<cr>",      desc = "Find file in explorer" },
      { "<leader>er", "<cmd>NvimTreeRefresh<cr>",              desc = "Refresh explorer" },
      { "<leader>ec", "<cmd>NvimTreeCollapse<cr>",             desc = "Collapse explorer" },
    },
    opts = {
      filters = {
        dotfiles = false,
        custom = { ".DS_Store", "__pycache__", ".git" },
      },
      disable_netrw = true,
      hijack_netrw = true,
      hijack_cursor = true,
      hijack_unnamed_buffer_when_opening = false,
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      view = {
        width = 32,
        side = "left",
        preserve_window_proportions = true,
        cursorline = true,
        float = {
          enable = false,
          quit_on_focus_loss = true,
          open_win_config = {
            relative = "editor",
            border = "rounded",
            width = 35,
            height = 30,
            row = 1,
            col = 1,
          },
        },
      },
      renderer = {
        root_folder_label = ":~:s?$?/..?",
        group_empty = true,
        indent_width = 2,
        indent_markers = {
          enable = true,
          inline_arrows = true,
          icons = {
            corner = "└",
            edge = "│",
            item = "│",
            bottom = "─",
            none = " ",
          },
        },
        highlight_git = "name",
        highlight_diagnostics = "icon",
        highlight_opened_files = "name",
        highlight_modified = "icon",
        icons = {
          web_devicons = { file = { enable = true, color = true }, folder = { enable = false } },
          git_placement = "after",
          modified_placement = "after",
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
            modified = true,
            diagnostics = true,
          },
          glyphs = {
            default  = "󰈚",
            symlink  = "",
            modified = "●",
            folder = {
              default      = "",
              empty        = "",
              empty_open   = "",
              open         = "",
              symlink      = "",
              symlink_open = "",
              arrow_open   = "",
              arrow_closed = "",
            },
            git = {
              unstaged  = "✗",
              staged    = "✓",
              unmerged  = "",
              renamed   = "➜",
              untracked = "★",
              deleted   = "",
              ignored   = "◌",
            },
          },
        },
      },
      modified = {
        enable = true,
        show_on_dirs = true,
        show_on_open_dirs = false,
      },
      git = {
        enable = true,
        ignore = false,
        show_on_dirs = true,
        show_on_open_dirs = false,
        timeout = 500,
      },
      actions = {
        open_file = {
          quit_on_open = false,
          resize_window = true,
          window_picker = {
            enable = true,
            picker = "default",
            chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
            exclude = {
              filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
              buftype = { "nofile", "terminal", "help" },
            },
          },
        },
        remove_file = { close_window = true },
      },
      diagnostics = {
        enable = true,
        show_on_dirs = true,
        show_on_open_dirs = false,
        debounce_delay = 50,
        severity = {
          min = vim.diagnostic.severity.HINT,
          max = vim.diagnostic.severity.ERROR,
        },
        icons = {
          hint    = "󰌵",
          info    = "",
          warning = "",
          error   = "",
        },
      },
      notify = { threshold = vim.log.levels.WARN },
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)
      -- Auto-close nvim-tree when it's the last window
      vim.api.nvim_create_autocmd("QuitPre", {
        callback = function()
          local tree_wins = {}
          local floating_wins = {}
          local wins = vim.api.nvim_list_wins()
          for _, w in ipairs(wins) do
            local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
            if bufname:match("NvimTree_") ~= nil then
              table.insert(tree_wins, w)
            end
            if vim.api.nvim_win_get_config(w).relative ~= "" then
              table.insert(floating_wins, w)
            end
          end
          if 1 == #wins - #floating_wins - #tree_wins then
            for _, w in ipairs(tree_wins) do
              vim.api.nvim_win_close(w, true)
            end
          end
        end,
      })
    end,
  },
}
