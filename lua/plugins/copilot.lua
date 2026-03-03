-- ── GitHub Copilot AI ────────────────────────────────────
-- Inline suggestions, cmp integration, and interactive chat
-- Inspired by LazyVim extras/ai/copilot.lua and popular community configs
--
-- FIRST TIME SETUP:
--   1. Open Neovim and run :Copilot auth
--   2. Follow the instructions to authenticate with your GitHub account
--   3. Once authenticated, Copilot will auto-suggest as you type
return {
  -- ── Copilot Core: Inline suggestions ──
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "BufReadPost",
    opts = {
      suggestion = {
        enabled = false, -- Disabled: we use copilot-cmp instead for unified completion
        auto_trigger = true,
        hide_during_completion = true,
        keymap = {
          accept = false, -- handled by nvim-cmp
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      panel = { enabled = false }, -- Disabled: we use CopilotChat instead
      filetypes = {
        markdown = true,
        help = true,
        gitcommit = true,
        yaml = true,
        toml = true,
        xml = true,
        -- Disable for sensitive files
        ["."] = false,
        sh = function()
          if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then
            return false
          end
          return true
        end,
      },
      copilot_node_command = "node", -- Ensure node is in PATH
    },
  },

  -- ── Copilot CMP Source: AI completions in nvim-cmp ──
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    event = { "InsertEnter", "LspAttach" },
    opts = {},
    config = function(_, opts)
      local copilot_cmp = require("copilot_cmp")
      copilot_cmp.setup(opts)
      -- Re-attach when copilot connects (fixes lazy-loading race)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.name == "copilot" then
            copilot_cmp._on_insert_enter({})
          end
        end,
      })
    end,
  },

  -- ── Copilot Chat: Interactive AI assistant ──
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    cmd = {
      "CopilotChat",
      "CopilotChatOpen",
      "CopilotChatClose",
      "CopilotChatToggle",
      "CopilotChatReset",
      "CopilotChatSave",
      "CopilotChatLoad",
      "CopilotChatPrompts",
      "CopilotChatModels",
    },
    opts = {
      model = "gpt-4.1",
      temperature = 0.1,
      auto_insert_mode = true,
      show_folds = true,
      show_help = true,
      window = {
        layout = "vertical",
        width = 0.4,
        border = "rounded",
      },
      mappings = {
        close = { normal = "q", insert = "<C-c>" },
        reset = { normal = "<C-l>", insert = "<C-l>" },
        submit_prompt = { normal = "<CR>", insert = "<C-s>" },
        accept_diff = { normal = "<C-y>", insert = "<C-y>" },
      },
    },
    keys = {
      -- Toggle chat window
      { "<leader>aa", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Copilot Chat", mode = { "n", "v" } },
      -- Quick chat with selection context
      { "<leader>aq", function()
        local input = vim.fn.input("Quick Chat: ")
        if input ~= "" then
          require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
        end
      end, desc = "Quick chat (buffer)", mode = { "n", "v" } },
      -- Predefined prompts
      { "<leader>ae", "<cmd>CopilotChatExplain<cr>",  desc = "Explain code",    mode = { "n", "v" } },
      { "<leader>ar", "<cmd>CopilotChatReview<cr>",   desc = "Review code",     mode = { "n", "v" } },
      { "<leader>af", "<cmd>CopilotChatFix<cr>",      desc = "Fix code",        mode = { "n", "v" } },
      { "<leader>ao", "<cmd>CopilotChatOptimize<cr>",  desc = "Optimize code",   mode = { "n", "v" } },
      { "<leader>ad", "<cmd>CopilotChatDocs<cr>",     desc = "Generate docs",   mode = { "n", "v" } },
      { "<leader>at", "<cmd>CopilotChatTests<cr>",    desc = "Generate tests",  mode = { "n", "v" } },
      { "<leader>ac", "<cmd>CopilotChatCommit<cr>",   desc = "Generate commit msg" },
      -- Model & prompt selection
      { "<leader>am", "<cmd>CopilotChatModels<cr>",   desc = "Select AI model" },
      { "<leader>ap", "<cmd>CopilotChatPrompts<cr>",  desc = "Select prompt" },
      -- Reset/save/load
      { "<leader>ax", "<cmd>CopilotChatReset<cr>",    desc = "Reset chat" },
      { "<leader>as", "<cmd>CopilotChatSave<cr>",     desc = "Save chat" },
      { "<leader>al", "<cmd>CopilotChatLoad<cr>",     desc = "Load chat" },
    },
  },

  -- ── Copilot Lualine: Status indicator in statusline ──
  {
    "AndreM222/copilot-lualine",
    dependencies = { "zbirenbaum/copilot.lua" },
    lazy = true,
  },
}
