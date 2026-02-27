-- ── UI Enhancements ──────────────────────────────────────
-- Inspired by LazyVim, AstroNvim, NvChad
return {
  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        vim.o.statusline = " "
      else
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      -- Show macro recording in lualine
      local function macro_recording()
        local reg = vim.fn.reg_recording()
        if reg ~= "" then return "Recording @" .. reg end
        return ""
      end

      local function lsp_clients()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if not clients or #clients == 0 then
          return ""
        end
        local names = {}
        for _, c in ipairs(clients) do
          if c.name ~= "copilot" then
            table.insert(names, c.name)
          end
        end
        if #names == 0 then
          return ""
        end
        return "LSP:" .. table.concat(names, ",")
      end

      return {
        options = {
          theme = "auto",
          globalstatus = true,
          component_separators = { left = "│", right = "│" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = { "dashboard", "alpha", "ministarter" },
          },
        },
        sections = {
          lualine_a = { { "mode", fmt = function(s) return s:sub(1, 3) end } },
          lualine_b = {
            { "branch", icon = "" },
            {
              "diff",
              symbols = { added = " ", modified = " ", removed = " " },
              source = function()
                local gs = vim.b.gitsigns_status_dict
                if gs then
                  return { added = gs.added, modified = gs.changed, removed = gs.removed }
                end
              end,
            },
          },
          lualine_c = {
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            {
              "filename",
              path = 1,
              symbols = { modified = " ●", readonly = " 󰌾", unnamed = "[No Name]", newfile = "[New]" },
            },
          },
          lualine_x = {
            {
              macro_recording,
              color = { fg = "#ff9e64" },
            },
            -- Copilot status indicator
            {
              "copilot",
              show_colors = true,
              show_loading = true,
            },
            {
              lsp_clients,
              color = { fg = "#89b4fa" },
            },
            {
              "diagnostics",
              symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
            },
            {
              function() return require("lazy.status").updates() end,
              cond = function() return package.loaded["lazy"] and require("lazy.status").has_updates() end,
              color = { fg = "#ff9e64" },
            },
          },
          lualine_y = {
            { "filetype", icon_only = false },
            { "encoding", show_bomb = true, fmt = function(s) return s ~= "utf-8" and s or "" end },
            {
              "fileformat",
              symbols = { unix = "", dos = "", mac = "" },
              fmt = function(s) return s ~= "" and s or "" end,
            },
          },
          lualine_z = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
        },
        extensions = { "nvim-tree", "lazy", "mason", "quickfix", "man" },
      }
    end,
  },

  -- Buffer tabs
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode = "buffers",
        numbers = "none",
        close_command = function(n) Snacks.bufdelete(n) end,
        right_mouse_command = function(n) Snacks.bufdelete(n) end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icons = { error = " ", warning = " ", hint = "󰌵 ", info = " " }
          local ret = (diag.error and icons.error .. diag.error .. " " or "")
            .. (diag.warning and icons.warning .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          { filetype = "NvimTree", text = "Explorer", highlight = "Directory", separator = true },
        },
        separator_style = "thin",
        show_buffer_close_icons = true,
        show_close_icon = false,
        show_tab_indicators = true,
        persist_buffer_sort = true,
        color_icons = true,
        enforce_regular_tabs = false,
        max_name_length = 30,
        max_prefix_length = 15,
        tab_size = 21,
        hover = { enabled = true, delay = 200, reveal = { "close" } },
      },
    },
    keys = {
      { "<leader>bp",  "<cmd>BufferLineTogglePin<cr>",            desc = "Pin buffer" },
      { "<leader>bP",  "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Delete non-pinned buffers" },
      { "<leader>bl",  "<cmd>BufferLineCloseRight<cr>",           desc = "Close buffers to the right" },
      { "<leader>bh",  "<cmd>BufferLineCloseLeft<cr>",            desc = "Close buffers to the left" },
      { "<leader>bs",  "<cmd>BufferLineSortByDirectory<cr>",      desc = "Sort by directory" },
      { "<leader>bS",  "<cmd>BufferLineSortByExtension<cr>",      desc = "Sort by extension" },
      { "<S-h>",       "<cmd>BufferLineCyclePrev<cr>",             desc = "Prev buffer" },
      { "<S-l>",       "<cmd>BufferLineCycleNext<cr>",             desc = "Next buffer" },
      { "[b",          "<cmd>BufferLineCyclePrev<cr>",             desc = "Prev buffer" },
      { "]b",          "<cmd>BufferLineCycleNext<cr>",             desc = "Next buffer" },
      { "[B",          "<cmd>BufferLineMovePrev<cr>",             desc = "Move buffer prev" },
      { "]B",          "<cmd>BufferLineMoveNext<cr>",             desc = "Move buffer next" },
      { "<leader>b1",  "<cmd>BufferLineGoToBuffer 1<cr>",         desc = "Go to buffer 1" },
      { "<leader>b2",  "<cmd>BufferLineGoToBuffer 2<cr>",         desc = "Go to buffer 2" },
      { "<leader>b3",  "<cmd>BufferLineGoToBuffer 3<cr>",         desc = "Go to buffer 3" },
      { "<leader>b4",  "<cmd>BufferLineGoToBuffer 4<cr>",         desc = "Go to buffer 4" },
    },
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = {
        enabled = true,
        show_start = true,
        show_end = false,
        highlight = { "Function", "Label" },
      },
      exclude = {
        filetypes = {
          "help", "dashboard", "alpha", "lazy", "mason",
          "notify", "NvimTree", "Trouble", "trouble",
          "toggleterm", "lazyterm",
        },
      },
    },
  },

  -- Which key (keybinding help)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
      defaults = {},
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>a",  group = "AI/Copilot", icon = " " },
        { "<leader>b",  group = "Buffer" },
        { "<leader>c",  group = "Code" },
        { "<leader>e",  group = "Explorer" },
        { "<leader>f",  group = "Find" },
        { "<leader>g",  group = "Git" },
        { "<leader>gh", group = "Hunks" },
        { "<leader>gt", group = "Toggle" },
        { "<leader>l",  group = "LSP/Lazy" },
        { "<leader>m",  group = "Markdown" },
        { "<leader>n",  group = "Notifications" },
        { "<leader>p",  group = "Yank/Paste" },
        { "<leader>q",  group = "Quit/Session" },
        { "<leader>r",  group = "Refactor/Rename" },
        { "<leader>s",  group = "Search/Replace" },
        { "<leader>u",  group = "UI/Toggle" },
        { "<leader>w",  group = "Windows/Save" },
        { "<leader>x",  group = "Diagnostics" },
        { "<leader><tab>",  group = "Tabs" },
        { "[",          group = "Prev" },
        { "]",          group = "Next" },
        { "g",          group = "Goto" },
        { "gs",         group = "Surround" },
        { "z",          group = "Fold" },
      })
    end,
  },

  -- Notifications (noice replaces notify for a better experience)
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        hover = { enabled = true },
        signature = { enabled = true },
      },
      routes = {
        -- Hide "written" messages
        { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
        -- Hide search count messages
        { filter = { event = "msg_show", kind = "search_count" }, opts = { skip = true } },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
    },
    keys = {
      { "<leader>un", function() require("noice").cmd("dismiss") end, desc = "Dismiss notifications" },
      { "<leader>nh", function() require("noice").cmd("history") end, desc = "Notification history" },
      { "<leader>na", function() require("noice").cmd("all") end,     desc = "All notifications" },
    },
  },

  -- Notify (used by noice)
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 2000,
      max_height = function() return math.floor(vim.o.lines * 0.75) end,
      max_width = function() return math.floor(vim.o.columns * 0.75) end,
      render = "wrapped-compact",
      stages = "fade",
      top_down = true,
    },
  },

  -- Better UI for inputs/selects (fallback, telescope-ui-select also handles this)
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  -- Color highlighter (show hex colors inline)
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      user_default_options = {
        css = true,
        tailwind = true,
        mode = "virtualtext",
        virtualtext = "■",
        names = false,
        rgb_fn = true,
        hsl_fn = true,
        RRGGBBAA = true,
      },
      filetypes = {
        "*",
        "!lazy",
        "!mason",
      },
    },
  },

  -- Winbar breadcrumbs
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      bar = {
        enable = function(buf, win, _)
          return vim.bo[buf].buftype == ""
            and vim.api.nvim_win_get_config(win).relative == ""
        end,
      },
      menu = { quick_navigation = true },
    },
  },

  -- Scrollbar with diagnostics and git marks
  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      show_in_active_only = true,
      handlers = { diagnostic = true, gitsigns = true },
    },
    config = function(_, opts)
      require("scrollbar").setup(opts)
      require("scrollbar.handlers.diagnostic").setup()
      require("scrollbar.handlers.gitsigns").setup()
    end,
  },

  -- Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      signs_staged = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 500,
      },
      current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        -- Navigation
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev hunk")
        map("n", "]H", function() gs.nav_hunk("last") end, "Last hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First hunk")
        -- Actions
        map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
        map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
        map("n", "<leader>ghS", gs.stage_buffer,    "Stage buffer")
        map("n", "<leader>ghR", gs.reset_buffer,    "Reset buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview hunk inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>ghB", function() gs.blame() end, "Blame buffer")
        map("n", "<leader>ghd", gs.diffthis,        "Diff this")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff this ~")
        map("n", "<leader>gtb", gs.toggle_current_line_blame, "Toggle line blame")
        map("n", "<leader>gtd", gs.toggle_deleted,  "Toggle deleted")
        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
      end,
    },
  },

  -- Diffview: rich Git diffs and history
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>",           desc = "Diffview" },
      { "<leader>gD", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>",   desc = "Branch history" },
    },
    opts = {
      view = {
        merge_tool = {
          layout = "diff3_mixed",
          disable_diagnostics = true,
        },
      },
      file_panel = {
        listing_style = "tree",
        win_config = { width = 38 },
      },
    },
  },

  -- Trouble (better diagnostics list)
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location list (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix list (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>",      desc = "Symbols (Trouble)" },
      { "<leader>cS", "<cmd>Trouble lsp toggle<cr>",                     desc = "LSP references/definitions (Trouble)" },
    },
  },

  -- Mini indentscope: animated indent scope visualization (popular in LazyVim)
  {
    "echasnovski/mini.indentscope",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help", "dashboard", "alpha", "neo-tree", "NvimTree", "Trouble",
          "trouble", "lazy", "mason", "notify", "toggleterm", "lazyterm",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },
}
