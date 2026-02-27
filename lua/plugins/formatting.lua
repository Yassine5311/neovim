-- ── Formatting & Linting ─────────────────────────────────
-- Inspired by LazyVim
return {
  -- Autoformat on save
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "Format buffer" },
      { "<leader>cF", function() require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 }) end, desc = "Format injected langs" },
      { "<leader>uf", function()
        vim.g.autoformat = not vim.g.autoformat
        vim.notify(vim.g.autoformat and "Autoformat enabled" or "Autoformat disabled")
      end, desc = "Toggle format on save" },
    },
    init = function()
      vim.g.autoformat = true
    end,
    opts = {
      formatters_by_ft = {
        lua        = { "stylua" },
        python     = { "ruff_format", "ruff_organize_imports" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        html       = { "prettierd", "prettier", stop_after_first = true },
        css        = { "prettierd", "prettier", stop_after_first = true },
        scss       = { "prettierd", "prettier", stop_after_first = true },
        json       = { "prettierd", "prettier", stop_after_first = true },
        jsonc      = { "prettierd", "prettier", stop_after_first = true },
        yaml       = { "prettierd", "prettier", stop_after_first = true },
        markdown   = { "prettierd", "prettier", stop_after_first = true },
        graphql    = { "prettierd", "prettier", stop_after_first = true },
        go         = { "goimports", "gofumpt" },
        rust       = { "rustfmt" },
        c          = { "clang-format" },
        cpp        = { "clang-format" },
        sh         = { "shfmt" },
        bash       = { "shfmt" },
        fish       = { "fish_indent" },
        toml       = { "taplo" },
        zig        = { "zigfmt" },
        ["_"]      = { "trim_whitespace" },
      },
      format_on_save = function(bufnr)
        if not vim.g.autoformat then return end
        -- Disable for filetypes that are slow or unwanted
        local disable_filetypes = { sql = true, text = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then return end
        return {
          timeout_ms = 3000,
          lsp_fallback = true,
        }
      end,
      formatters = {
        shfmt = { prepend_args = { "-i", "2" } },
      },
    },
  },

  -- Linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python     = { "ruff" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        go         = { "golangcilint" },
        sh         = { "shellcheck" },
        bash       = { "shellcheck" },
        fish       = { "fish" },
        dockerfile = { "hadolint" },
      }

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("Lint", { clear = true }),
        callback = function()
          -- Only lint if the linter binary exists
          local ft = vim.bo.filetype
          local linters = lint.linters_by_ft[ft] or {}
          for _, linter in ipairs(linters) do
            local cmd = lint.linters[linter] and lint.linters[linter].cmd
            if cmd and vim.fn.executable(cmd) == 1 then
              lint.try_lint(linter)
            end
          end
        end,
      })

      vim.keymap.set("n", "<leader>cl", function() lint.try_lint() end, { desc = "Trigger linting" })
    end,
  },
}
