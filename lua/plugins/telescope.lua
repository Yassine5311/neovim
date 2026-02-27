-- ── Telescope (Fuzzy Finder) ─────────────────────────────
-- Inspired by LazyVim, AstroNvim
return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end,
      },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      -- Find
      { "<leader>ff", "<cmd>Telescope find_files<cr>",                          desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",                           desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",                           desc = "Help tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                            desc = "Recent files" },
      { "<leader>fd", "<cmd>Telescope diagnostics bufnr=0<cr>",                 desc = "Document diagnostics" },
      { "<leader>fD", "<cmd>Telescope diagnostics<cr>",                         desc = "Workspace diagnostics" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>",                desc = "Document symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",       desc = "Workspace symbols" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>",                         desc = "Find word under cursor" },
      { "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<cr>",           desc = "Fuzzy find in buffer" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>",                             desc = "Keymaps" },
      { "<leader>fm", "<cmd>Telescope marks<cr>",                               desc = "Marks" },
      { "<leader>fR", "<cmd>Telescope resume<cr>",                              desc = "Resume last search" },
      { "<leader>f\"", "<cmd>Telescope registers<cr>",                          desc = "Registers" },
      { "<leader>fc", "<cmd>Telescope commands<cr>",                            desc = "Commands" },
      -- Search config
      { "<leader>fn", function() require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") }) end, desc = "Neovim config files" },
      -- Git
      { "<leader>gc", "<cmd>Telescope git_commits<cr>",                         desc = "Git commits" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>",                          desc = "Git status" },
      { "<leader>gb", "<cmd>Telescope git_branches<cr>",                        desc = "Git branches" },
      { "<leader>gS", "<cmd>Telescope git_stash<cr>",                           desc = "Git stash" },
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          prompt_prefix = "   ",
          selection_caret = "  ",
          entry_prefix = "  ",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          file_ignore_patterns = {
            "node_modules", ".git/", "target/", "dist/", "build/",
            "%.lock", "__pycache__", "%.pyc", "%.o", "%.a",
            "%.out", "%.class", "%.pdf", "%.mkv", "%.mp4", "%.zip",
          },
          path_display = { "truncate" },
          winblend = 0,
          border = true,
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          set_env = { COLORTERM = "truecolor" },
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case", "--hidden",
            "--glob", "!**/.git/*",
          },
          mappings = {
            i = {
              ["<C-j>"]  = actions.move_selection_next,
              ["<C-k>"]  = actions.move_selection_previous,
              ["<C-n>"]  = actions.cycle_history_next,
              ["<C-p>"]  = actions.cycle_history_prev,
              ["<C-q>"]  = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-d>"]  = actions.delete_buffer,
              ["<Esc>"]  = actions.close,
            },
            n = {
              ["q"]      = actions.close,
              ["<C-q>"]  = actions.send_selected_to_qflist + actions.open_qflist,
              ["dd"]     = actions.delete_buffer,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
          },
          buffers = {
            theme = "dropdown",
            previewer = false,
            mappings = {
              i = { ["<C-d>"] = actions.delete_buffer },
              n = { ["dd"] = actions.delete_buffer },
            },
          },
          live_grep = {
            additional_args = { "--hidden" },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
    end,
  },
}
