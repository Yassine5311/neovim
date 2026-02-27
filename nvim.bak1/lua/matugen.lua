local M = {}

function M.setup()
  require('base16-colorscheme').setup {
    -- Background tones
    base00 = '#131316', -- Default Background
    base01 = '#1f1f22', -- Lighter Background (status bars)
    base02 = '#292a2d', -- Selection Background
    base03 = '#8f9099', -- Comments, Invisibles
    -- Foreground tones
    base04 = '#c5c6cf', -- Dark Foreground (status bars)
    base05 = '#e4e2e6', -- Default Foreground
    base06 = '#e4e2e6', -- Light Foreground
    base07 = '#e4e2e6', -- Lightest Foreground
    -- Accent colors
    base08 = '#ffb4ab', -- Variables, XML Tags, Errors
    base09 = '#e2b9e8', -- Integers, Constants
    base0A = '#c0c6db', -- Classes, Search Background
    base0B = '#b4c6f5', -- Strings, Diff Inserted
    base0C = '#e2b9e8', -- Regex, Escape Chars
    base0D = '#b4c6f5', -- Functions, Methods
    base0E = '#c0c6db', -- Keywords, Storage
    base0F = '#93000a', -- Deprecated, Embedded Tags
  }
end

-- Register a signal handler for SIGUSR1 (noctalia/matugen updates)
local signal = vim.uv.new_signal()
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
