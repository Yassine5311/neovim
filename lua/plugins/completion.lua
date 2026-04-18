-- ── Autocompletion ───────────────────────────────────────
-- Replaced nvim-cmp with blink.cmp (2026 standard)
return {
  {
    'saghen/blink.cmp',
    version = '*' ,
    dependencies = {
      'L3MON4D3/LuaSnip',
      'rafamadriz/friendly-snippets',
    },
    event = 'InsertEnter',
    opts = {
      snippets = {
        preset = 'luasnip',
      },
      keymap = { 
        preset = 'super-tab',
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono'
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      signature = { enabled = true }
    },
  }
}
