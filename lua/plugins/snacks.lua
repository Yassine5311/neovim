-- ── Snacks.nvim (QoL utilities) ──────────────────────────
-- Inspired by LazyVim's snacks integration
-- Adds: bigfile, bufdelete, lazygit, terminal, gitbrowse,
-- words, quickfile, rename, zen, scratch, toggle, and more
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- Handle big files gracefully (disable heavy features)
      bigfile = { enabled = true },
      -- Faster file rendering on startup
      quickfile = { enabled = true },
      -- LSP word highlighting & navigation
      words = { enabled = true },
      -- Better vim.ui.input
      input = { enabled = true },
      -- Status column with signs, line numbers, and fold indicators
      statuscolumn = { enabled = true },
      -- Notifications (modern replacement, used by many LazyVim users)
      notifier = {
        enabled = true,
        timeout = 3000,
        style = "compact",
      },
      -- Smooth scrolling animations
      scroll = {
        enabled = true,
        animate = {
          duration = { step = 15, total = 150 },
          easing = "linear",
        },
        filter = function(buf)
          return vim.g.snacks_scroll ~= false
            and vim.b[buf].snacks_scroll ~= false
            and vim.bo[buf].buftype ~= "terminal"
        end,
      },
      -- Animated indent scope (like mini.indentscope but integrated)
      indent = {
        enabled = true,
        indent = { char = "│", only_scope = false, only_current = false },
        animate = { enabled = true, style = "out" },
        scope = { enabled = true, char = "│" },
      },
      -- Image viewer for supported terminals (kitty, wezterm, etc.)
      image = { enabled = true },
      -- Dashboard (replaces dashboard-nvim if desired, or keep both)
      -- Dim inactive windows (like TwilightMode)
      dim = { enabled = true },
      -- Git integration
      git = { enabled = true },
      -- Picker for gitlog
      picker = { enabled = true },
    },
    keys = {
      -- Buffer delete (preserves window layout)
      { "<leader>bd", function() Snacks.bufdelete() end,            desc = "Delete buffer" },
      { "<leader>bD", function() Snacks.bufdelete.other() end,      desc = "Delete other buffers" },

      -- Lazygit
      { "<leader>gg", function() Snacks.lazygit() end,              desc = "Lazygit" },
      { "<leader>gl", function() Snacks.lazygit.log() end,          desc = "Lazygit log (cwd)" },
      { "<leader>gf", function() Snacks.lazygit.log_file() end,     desc = "Lazygit log (file)" },

      -- Terminal (floating)
      { "<c-/>",      function() Snacks.terminal() end,             desc = "Toggle terminal" },
      { "<c-_>",      function() Snacks.terminal() end,             desc = "which_key_ignore" },

      -- Git browse (open in browser)
      { "<leader>gB", function() Snacks.gitbrowse() end,            desc = "Git browse", mode = { "n", "v" } },

      -- LSP file rename
      { "<leader>cR", function() Snacks.rename.rename_file() end,   desc = "Rename file" },

      -- LSP word navigation (references)
      { "]]",         function() Snacks.words.jump(vim.v.count1) end,  desc = "Next reference", mode = { "n", "t" } },
      { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev reference", mode = { "n", "t" } },

      -- Zen mode
      { "<leader>z",  function() Snacks.zen() end,                  desc = "Zen mode" },
      { "<leader>Z",  function() Snacks.zen.zoom() end,             desc = "Zen zoom" },

      -- Scratch buffers
      { "<leader>.",  function() Snacks.scratch() end,              desc = "Scratch buffer" },
      { "<leader>S",  function() Snacks.scratch.select() end,       desc = "Select scratch buffer" },

      -- Dismiss notifications
      { "<leader>uN", function() Snacks.notifier.hide() end,        desc = "Dismiss notifications" },

      -- Notification history
      { "<leader>nh", function() Snacks.notifier.show_history() end, desc = "Notification history" },

      -- Dim toggle
      { "<leader>uD", function() Snacks.dim() end,                  desc = "Toggle dim mode" },

      -- Profiler (useful for debugging startup)
      { "<leader>ps", function() Snacks.profiler.scratch() end,     desc = "Profiler scratch" },

      -- Neovim News
      { "<leader>N", desc = "Neovim News", function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        })
      end },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- Debug helpers (lazy-loaded)
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd

          -- Toggle mappings (integrated with which-key)
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle.option("conceallevel", {
            off = 0,
            on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
          }):map("<leader>uc")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle.option("background", {
            off = "light",
            on = "dark",
            name = "Dark Background",
          }):map("<leader>ub")
          Snacks.toggle.inlay_hints():map("<leader>uh")
        end,
      })
    end,
  },
}
