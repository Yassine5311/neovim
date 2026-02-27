-- ── Colorscheme: Matugen via base16 ──────────────────────
-- Matugen generates ~/.config/nvim/lua/matugen.lua from matugen-template.lua
-- The base16 colorscheme is applied via require('matugen').setup()
-- Live reload: pkill -SIGUSR1 nvim (triggered automatically by matugen)
return {
  {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- Load matugen-generated theme (with SIGUSR1 live-reload handler)
      local ok, matugen = pcall(require, "matugen")
      if ok and matugen.setup then
        matugen.setup()
      else
        -- Fallback if matugen.lua hasn't been generated yet
        vim.cmd.colorscheme("base16-default-dark")
      end

      -- Auto-reload when matugen.lua changes on disk
      local matugen_path = vim.fn.stdpath("config") .. "/lua/matugen.lua"
      local uv = vim.uv
      if uv and uv.new_fs_event then
        local timer = uv.new_timer()
        local watcher = uv.new_fs_event()
        watcher:start(matugen_path, {}, function()
          if timer then
            timer:stop()
            timer:start(100, 0, function()
              vim.schedule(function()
                package.loaded["matugen"] = nil
                local ok_reload, mod = pcall(require, "matugen")
                if ok_reload and mod.setup then
                  mod.setup()
                end
              end)
            end)
          end
        end)
      end
    end,
  },
}