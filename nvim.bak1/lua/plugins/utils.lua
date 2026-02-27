-- ── Utility Plugins ──────────────────────────────────────
-- Inspired by LazyVim, AstroNvim
return {
  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup({
        check_ts = true,
        ts_config = {
          lua = { "string", "source" },
          javascript = { "string", "template_string" },
          typescript = { "string", "template_string" },
        },
        disable_filetype = { "TelescopePrompt", "spectre_panel" },
        fast_wrap = {
          map = "<M-e>",
          chars = { "{", "[", "(", '"', "'" },
          pattern = [=[[%'%"%>%]%)%}%,]]=],
          end_key = "$",
          before_key = "h",
          after_key = "l",
          cursor_pos_before = true,
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          highlight = "PmenuSel",
          highlight_grey = "LineNr",
        },
      })
      -- Integrate with cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Surround (add/change/delete brackets, quotes, etc.)
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Comment toggling (Neovim >= 0.10 has native gc, but this adds extras)
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n",          desc = "Comment toggle line" },
      { "gc",  mode = { "n", "v" }, desc = "Comment toggle" },
      { "gbc", mode = "n",          desc = "Comment toggle block" },
      { "gb",  mode = { "n", "v" }, desc = "Comment toggle block" },
    },
    opts = {},
  },

  -- Todo comments highlighting
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = true,
      highlight = {
        multiline = true,
        before = "",
        keyword = "wide",
        after = "fg",
        pattern = [[.*<(KEYWORDS)\s*:]],
      },
      search = {
        command = "rg",
        args = { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column" },
        pattern = [=[\b(KEYWORDS):]=],
      },
    },
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>",                          desc = "Find TODOs" },
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
    },
  },

  -- Smooth scrolling
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {
      mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "zt", "zz", "zb" },
      hide_cursor = true,
      stop_eof = true,
      respect_scrolloff = false,
      cursor_scrolls_alone = true,
      easing = "quadratic",
    },
  },

  -- Tmux navigation (only loads if inside tmux)
  {
    "christoomey/vim-tmux-navigator",
    cond = function() return vim.env.TMUX ~= nil end,
    event = "VeryLazy",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
  },

  -- Session persistence (LazyVim pattern)
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = vim.opt.sessionoptions:get() },
    keys = {
      { "<leader>qs", function() require("persistence").load() end,                desc = "Restore session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>qd", function() require("persistence").stop() end,                desc = "Don't save session" },
    },
  },

  -- Better text objects (LazyVim pattern)
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          c = ai.gen_spec.treesitter({ a = "@class.outer",    i = "@class.inner" }),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().googletag.pubads().-googletag.enableServices()<googletag.pubads()%1>" },
          d = { "%f[%d]%d+" }, -- digits
          e = { -- word with case
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          u = ai.gen_spec.function_call(),                   -- u for "Usage" (function call)
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in name
        },
      }
    end,
  },

  -- Flash (better navigation, replaces hop/leap)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",                function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },       function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },             function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
  },
}
