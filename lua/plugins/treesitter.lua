-- ── Treesitter: Syntax Highlighting ──────────────────────
-- Inspired by LazyVim, AstroNvim, NvChad
return {
  -- Parser installation and queries
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    branch = "main",
    event = { "BufReadPost", "BufNewFile", "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSInstallInfo" },
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "bash", "c", "cpp", "cmake", "css", "diff", "dockerfile", "fish",
          "git_config", "git_rebase", "gitcommit", "gitignore",
          "go", "gomod", "gowork", "gosum",
          "html", "http", "javascript", "jsdoc", "json", "json5", "jsonc",
          "lua", "luadoc", "luap",
          "make", "markdown", "markdown_inline",
          "nix", "printf", "python",
          "query", "regex", "rust", "ron",
          "scss", "sql", "svelte",
          "toml", "tsx", "typescript",
          "vim", "vimdoc", "vue",
          "xml", "yaml", "zig",
        },
      })
      -- Enable treesitter-based highlighting and indentation
      vim.treesitter.start = vim.treesitter.start or function() end
    end,
  },

  -- Textobjects (select, move, swap)
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local ts_textobjects = require("nvim-treesitter-textobjects")
      ts_textobjects.setup({
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")
      local ts_repeat = require("nvim-treesitter-textobjects.repeatable_move")

      -- Select textobjects
      local select_maps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
        ["ai"] = "@conditional.outer",
        ["ii"] = "@conditional.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
        ["ab"] = "@block.outer",
        ["ib"] = "@block.inner",
      }
      for key, query in pairs(select_maps) do
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(query, "textobjects")
        end, { desc = "Select " .. query })
      end

      -- Move to textobjects
      local move_maps = {
        ["]f"] = { move.goto_next_start, "@function.outer", "Next function start" },
        ["]c"] = { move.goto_next_start, "@class.outer", "Next class start" },
        ["]a"] = { move.goto_next_start, "@parameter.inner", "Next argument" },
        ["]F"] = { move.goto_next_end, "@function.outer", "Next function end" },
        ["]C"] = { move.goto_next_end, "@class.outer", "Next class end" },
        ["[f"] = { move.goto_previous_start, "@function.outer", "Prev function start" },
        ["[c"] = { move.goto_previous_start, "@class.outer", "Prev class start" },
        ["[a"] = { move.goto_previous_start, "@parameter.inner", "Prev argument" },
        ["[F"] = { move.goto_previous_end, "@function.outer", "Prev function end" },
        ["[C"] = { move.goto_previous_end, "@class.outer", "Prev class end" },
      }
      for key, val in pairs(move_maps) do
        vim.keymap.set({ "n", "x", "o" }, key, function()
          val[1](val[2], "textobjects")
        end, { desc = val[3] })
      end

      -- Swap parameters
      vim.keymap.set("n", "<leader>a", function()
        swap.swap_next("@parameter.inner")
      end, { desc = "Swap next arg" })
      vim.keymap.set("n", "<leader>A", function()
        swap.swap_previous("@parameter.inner")
      end, { desc = "Swap prev arg" })

      -- Repeatable moves with ; and ,
      vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat.repeat_last_move_next)
      vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat.repeat_last_move_previous)
      -- Make builtin f, F, t, T repeatable too
      vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat.builtin_f_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat.builtin_F_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat.builtin_t_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat.builtin_T_expr, { expr = true })
    end,
  },

  -- Sticky context at top of buffer (shows which function/class you're in)
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      enable = true,
      max_lines = 3,
      min_window_height = 20,
      multiline_threshold = 5,
      mode = "cursor",
    },
    keys = {
      { "<leader>ut", function() require("treesitter-context").toggle() end, desc = "Toggle treesitter context" },
      { "[t", function() require("treesitter-context").go_to_context(vim.v.count1) end, desc = "Go to context" },
    },
  },
}
