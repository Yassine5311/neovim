-- ── Coding Enhancements ──────────────────────────────────
-- Plugins that enhance the coding experience, inspired by
-- LazyVim, ThePrimeagen, TJ DeVries, and other popular configs
return {
  -- Yanky: Better yank/paste with ring history (LazyVim extra)
  {
    "gbprod/yanky.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ring = {
        history_length = 100,
        storage = "shada",
        sync_with_numbered_registers = true,
        cancel_event = "update",
      },
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 200,
      },
      preserve_cursor_position = { enabled = true },
      textobj = { enabled = true },
    },
    keys = {
      -- Replace default p/P with yanky for cycling
      { "p",          "<Plug>(YankyPutAfter)",          mode = { "n", "x" }, desc = "Put after" },
      { "P",          "<Plug>(YankyPutBefore)",         mode = { "n", "x" }, desc = "Put before" },
      { "gp",         "<Plug>(YankyGPutAfter)",         mode = { "n", "x" }, desc = "GPut after" },
      { "gP",         "<Plug>(YankyGPutBefore)",        mode = { "n", "x" }, desc = "GPut before" },
      -- Cycle through yank ring
      { "<C-p>",      "<Plug>(YankyPreviousEntry)",     desc = "Previous yank" },
      { "<C-n>",      "<Plug>(YankyNextEntry)",         desc = "Next yank" },
      -- Put with indent adjustment
      { "]p",         "<Plug>(YankyPutIndentAfterLinewise)",  desc = "Put indented after" },
      { "[p",         "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before" },
      { "]P",         "<Plug>(YankyPutIndentAfterLinewise)",  desc = "Put indented after" },
      { "[P",         "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before" },
      -- Telescope yank history
      { "<leader>p",  function() require("telescope").extensions.yank_history.yank_history({}) end, desc = "Yank history" },
    },
    config = function(_, opts)
      require("yanky").setup(opts)
      require("telescope").load_extension("yank_history")
    end,
  },

  -- ts-comments: Context-aware comment strings (JSX, TSX, Vue, etc.) — LazyVim
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Flash: Navigate your code with search labels, enhanced character motions, and Treesitter integration
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  -- Mini.ai: Better text objects (args, function call, etc.)
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
    end,
  },

  -- Neogen: Docstring/annotation generator (supports multiple languages)
  {
    "danymat/neogen",
    cmd = "Neogen",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
      { "<leader>cn", function() require("neogen").generate() end,                        desc = "Generate annotation" },
      { "<leader>cN", function() require("neogen").generate({ type = "file" }) end,       desc = "Generate file annotation" },
    },
    opts = {
      snippet_engine = "luasnip",
      languages = {
        lua = { template = { annotation_convention = "emmylua" } },
        python = { template = { annotation_convention = "google_docstrings" } },
        javascript = { template = { annotation_convention = "jsdoc" } },
        typescript = { template = { annotation_convention = "tsdoc" } },
        typescriptreact = { template = { annotation_convention = "tsdoc" } },
        go = { template = { annotation_convention = "godoc" } },
        rust = { template = { annotation_convention = "rustdoc" } },
        c = { template = { annotation_convention = "doxygen" } },
        cpp = { template = { annotation_convention = "doxygen" } },
      },
    },
  },

  -- Dial: Enhanced increment/decrement (true/false, dates, hex, etc.) — popular in many configs
  {
    "monaqa/dial.nvim",
    keys = {
      { "<C-a>",  function() return require("dial.map").inc_normal() end,  expr = true, desc = "Increment" },
      { "<C-x>",  function() return require("dial.map").dec_normal() end,  expr = true, desc = "Decrement" },
      { "g<C-a>", function() return require("dial.map").inc_gnormal() end, expr = true, desc = "Increment (additive)" },
      { "g<C-x>", function() return require("dial.map").dec_gnormal() end, expr = true, desc = "Decrement (additive)" },
      { "<C-a>",  function() return require("dial.map").inc_visual() end,  mode = "v",  expr = true, desc = "Increment" },
      { "<C-x>",  function() return require("dial.map").dec_visual() end,  mode = "v",  expr = true, desc = "Decrement" },
      { "g<C-a>", function() return require("dial.map").inc_gvisual() end, mode = "v",  expr = true, desc = "Increment (additive)" },
      { "g<C-x>", function() return require("dial.map").dec_gvisual() end, mode = "v",  expr = true, desc = "Decrement (additive)" },
    },
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.integer.alias.octal,
          augend.integer.alias.binary,
          augend.date.alias["%Y/%m/%d"],
          augend.date.alias["%Y-%m-%d"],
          augend.date.alias["%m/%d"],
          augend.date.alias["%H:%M"],
          augend.constant.alias.bool,
          augend.constant.alias.alpha,
          augend.constant.alias.Alpha,
          augend.semver.alias.semver,
          -- Custom toggles
          augend.constant.new({ elements = { "true", "false" } }),
          augend.constant.new({ elements = { "True", "False" } }),
          augend.constant.new({ elements = { "yes", "no" } }),
          augend.constant.new({ elements = { "Yes", "No" } }),
          augend.constant.new({ elements = { "on", "off" } }),
          augend.constant.new({ elements = { "On", "Off" } }),
          augend.constant.new({ elements = { "enable", "disable" } }),
          augend.constant.new({ elements = { "enabled", "disabled" } }),
          augend.constant.new({ elements = { "&&", "||" }, word = false }),
          augend.constant.new({ elements = { "and", "or" } }),
          augend.constant.new({ elements = { "let", "const" } }),
          augend.constant.new({ elements = { "public", "private", "protected" } }),
        },
      })
    end,
  },

  -- Undotree: Visual undo history — ThePrimeagen's must-have
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Toggle undotree" },
    },
  },

  -- Markdown Preview: Live preview in browser
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npx --yes yarn install",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview" },
    },
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_close = 1
    end,
  },

  -- Better quickfix window (LazyVim adjacent, very popular)
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
      auto_enable = true,
      auto_resize_height = true,
      preview = {
        win_height = 12,
        win_vheight = 12,
        delay_syntax = 80,
        border = "rounded",
        show_title = true,
      },
    },
  },

  -- Refactoring tools (ThePrimeagen)
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<leader>re", function() require("refactoring").refactor("Extract Function") end,         mode = "x", desc = "Extract function" },
      { "<leader>rf", function() require("refactoring").refactor("Extract Function To File") end, mode = "x", desc = "Extract function to file" },
      { "<leader>rv", function() require("refactoring").refactor("Extract Variable") end,         mode = "x", desc = "Extract variable" },
      { "<leader>rI", function() require("refactoring").refactor("Inline Function") end,          mode = "n", desc = "Inline function" },
      { "<leader>ri", function() require("refactoring").refactor("Inline Variable") end,          mode = { "n", "x" }, desc = "Inline variable" },
      { "<leader>rb", function() require("refactoring").refactor("Extract Block") end,            mode = "n", desc = "Extract block" },
      { "<leader>rB", function() require("refactoring").refactor("Extract Block To File") end,    mode = "n", desc = "Extract block to file" },
      -- Debug print statements
      { "<leader>rp", function() require("refactoring").debug.printf({ below = true }) end,       mode = "n", desc = "Debug print below" },
      { "<leader>rP", function() require("refactoring").debug.print_var() end,                    mode = { "n", "x" }, desc = "Debug print variable" },
      { "<leader>rc", function() require("refactoring").debug.cleanup({}) end,                    mode = "n", desc = "Debug cleanup" },
    },
    opts = {
      prompt_func_return_type = {
        go = true,
        cpp = true,
        c = true,
      },
      prompt_func_param_type = {
        go = true,
        cpp = true,
        c = true,
      },
    },
  },
}
