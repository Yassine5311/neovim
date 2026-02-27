-- ── Colorscheme: Noctalia/Matugen via base16 ──────────────
-- Noctalia generates ~/.config/nvim/lua/matugen.lua from the template.
-- The base16 colorscheme is applied via require('matugen').setup()
-- Live reload: pkill -SIGUSR1 nvim (triggered automatically by Noctalia)
return {
  {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- Try to load matugen-generated theme
      local ok, matugen = pcall(require, "matugen")
      if ok and matugen.setup then
        matugen.setup()
      else
        -- Fallback if matugen.lua hasn't been generated yet
        vim.cmd.colorscheme("base16-default-dark")
      end
    end,
  },
}
