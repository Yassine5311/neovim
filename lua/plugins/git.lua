-- ── Git Workflow ───────────────────────────────────────
-- Inspired by LazyVim and AstroNvim
return {
  {
    "NeogitOrg/neogit",
    cmd = { "Neogit" },
    keys = {
      { "<leader>gG", "<cmd>Neogit<cr>", desc = "Neogit" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    opts = {
      kind = "tab",
      disable_commit_confirmation = true,
      graph_style = "unicode",
      integrations = {
        diffview = true,
      },
    },
  },
}
