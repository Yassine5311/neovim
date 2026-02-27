-- ── Autocompletion ───────────────────────────────────────
-- Inspired by LazyVim, NvChad
return {
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help", -- signature help in completion
      "hrsh7th/cmp-emoji",                     -- emoji completion (:emoji:)
      "hrsh7th/cmp-calc",                      -- simple math/expr completion
      "zbirenbaum/copilot-cmp",                  -- GitHub Copilot AI completions
      "saadparwaiz1/cmp_luasnip",
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = {
          { "rafamadriz/friendly-snippets",
            config = function()
              require("luasnip.loaders.from_vscode").lazy_load()
              -- Load custom XML/XSD/DTD snippets
              require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
            end,
          },
        },
      },
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      luasnip.config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
      })

      -- Richer comparators for better sorting
      local compare = cmp.config.compare

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered({
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
            col_offset = -3,
            side_padding = 0,
          }),
          documentation = cmp.config.window.bordered({
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
            max_width = 80,
            max_height = 20,
          }),
        },
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            local kind = lspkind.cmp_format({
              mode = "symbol_text",
              maxwidth = 50,
              ellipsis_char = "…",
              symbol_map = { Copilot = "" },
            })(entry, vim_item)
            local strings = vim.split(kind.kind, "%s", { trimempty = true })
            kind.kind = " " .. (strings[1] or "") .. " "
            local menu = ({
              copilot  = "[AI]",
              nvim_lsp = "[LSP]",
              nvim_lua = "[API]",
              luasnip  = "[Snip]",
              buffer   = "[Buf]",
              path     = "[Path]",
              calc     = "[Calc]",
              cmdline  = "[Cmd]",
              nvim_lsp_signature_help = "[Sig]",
            })[entry.source.name] or ""
            kind.menu = "  " .. menu
            return kind
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          -- Super-Tab (LazyVim style)
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          -- C-n / C-p for selection (like native vim)
          ["<C-n>"]     = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"]     = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        }),
        sources = cmp.config.sources({
          { name = "copilot",               priority = 1100, group_index = 1 },
          { name = "nvim_lsp",               priority = 1000 },
          { name = "nvim_lua",               priority = 950 },
          { name = "luasnip",                priority = 750 },
          { name = "nvim_lsp_signature_help", priority = 700 },
          { name = "path",                   priority = 500 },
        }, {
          { name = "buffer", priority = 250, keyword_length = 3 },
          { name = "calc",   priority = 240 },
          { name = "emoji",  priority = 200 },
        }),
        sorting = {
          priority_weight = 2,
          comparators = {
            require("copilot_cmp.comparators").prioritize,
            compare.offset,
            compare.exact,
            compare.score,
            -- Prefer items from nearby scope
            function(entry1, entry2)
              local _, entry1_under = entry1.completion_item.label:find("^_+")
              local _, entry2_under = entry2.completion_item.label:find("^_+")
              entry1_under = entry1_under or 0
              entry2_under = entry2_under or 0
              if entry1_under > entry2_under then return false
              elseif entry1_under < entry2_under then return true end
            end,
            compare.recently_used,
            compare.locality,
            compare.kind,
            compare.length,
            compare.order,
          },
        },
        experimental = {
          ghost_text = { hl_group = "CmpGhostText" },
        },
      })

      -- Cmdline completions
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          { { name = "path" } },
          { { name = "cmdline", option = { ignore_cmds = { "Man", "!" } } } }
        ),
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })
    end,
  },
}
