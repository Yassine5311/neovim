-- ── LSP Configuration ────────────────────────────────────
-- Inspired by LazyVim, AstroNvim, NvChad
return {
  -- Mason: portable package manager for LSP servers, formatters, linters
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = " ",
          package_pending = " ",
          package_uninstalled = " ",
        },
      },
      ensure_installed = {
        "stylua", "shfmt",       -- formatters
        "prettierd",             -- web formatters
        "ruff",                  -- python linter/formatter
        "shellcheck",            -- shell linter
        "hadolint",              -- dockerfile linter
        "taplo",                 -- toml formatter
        "goimports", "gofumpt", "golangci-lint", -- go tools
        "clang-format",          -- C/C++ formatter
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      -- Auto-install ensure_installed tools
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },

  -- Bridge between mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "pyright",
        "ts_ls",
        "html",
        "cssls",
        "jsonls",
        "yamlls",
        "bashls",
        "clangd",
        "rust_analyzer",
        "gopls",
        "tailwindcss",
        "emmet_ls",
        "lemminx",
      },
      automatic_enable = true,
    },
  },

  -- LSP config
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      { "j-hui/fidget.nvim", opts = { notification = { window = { winblend = 0 } } } },
      { "folke/lazydev.nvim", ft = "lua", opts = {} }, -- better Neovim Lua development
      { "b0o/SchemaStore.nvim", lazy = true, version = false }, -- JSON/YAML schemas
    },
    config = function()
      -- Diagnostics config (modern API)
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          spacing = 4,
          source = "if_many",
        },
        float = {
          border = "rounded",
          source = "if_many",
          header = "",
          prefix = "",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = "󰌵 ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Note: hover/signature borders are handled by noice.nvim

      -- On attach keymaps (improved with Telescope integration)
      local on_attach = function(client, bufnr)
        local map = function(keys, func, desc, mode)
          mode = mode or "n"
          vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end

        map("gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, "Goto definition")
        map("gD", vim.lsp.buf.declaration, "Goto declaration")
        map("gr", function() require("telescope.builtin").lsp_references() end, "References")
        map("gi", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, "Goto implementation")
        map("gt", function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end, "Goto type definition")
        map("K", vim.lsp.buf.hover, "Hover documentation")
        map("gK", vim.lsp.buf.signature_help, "Signature help")
        map("<C-k>", vim.lsp.buf.signature_help, "Signature help", "i")

        map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
        map("<leader>cc", vim.lsp.codelens.run, "Run codelens", { "n", "v" })
        map("<leader>cC", vim.lsp.codelens.refresh, "Refresh codelens")
        map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
        map("<leader>cA", function()
          vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
        end, "Source action")

        -- Inlay hints toggle (LazyVim)
        if client.supports_method("textDocument/inlayHint") then
          map("<leader>uh", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
          end, "Toggle inlay hints")
        end

        -- Codelens support
        if client.supports_method("textDocument/codeLens") then
          vim.lsp.codelens.refresh()
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = bufnr,
            callback = vim.lsp.codelens.refresh,
          })
        end
      end

      -- Enhanced capabilities (for autocompletion)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem = {
        documentationFormat = { "markdown", "plaintext" },
        snippetSupport = true,
        preselectSupport = true,
        insertReplaceSupport = true,
        labelDetailsSupport = true,
        deprecatedSupport = true,
        commitCharactersSupport = true,
        tagSupport = { valueSet = { 1 } },
        resolveSupport = {
          properties = { "documentation", "detail", "additionalTextEdits" },
        },
      }
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }
      local cmp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if cmp_ok then
        capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
      end

      -- Register LspAttach autocommand for keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client then
            on_attach(client, ev.buf)
          end
        end,
      })

      -- Apply default capabilities to all servers via vim.lsp.config wildcard
      vim.lsp.config("*", {
        capabilities = capabilities,
        -- Support workspace file operations (rename, etc.)
        workspace = {
          fileOperations = {
            didRename = true,
            willRename = true,
          },
        },
      })

      -- Per-server configurations via vim.lsp.config
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
            completion = { callSnippet = "Replace" },
            hint = { enable = true },
            codeLens = { enable = true },
          },
        },
      })

      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      -- YAML language server with SchemaStore (popular in LazyVim/AstroNvim)
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas(),
            keyOrdering = false,
            format = { enable = true },
            validate = true,
            hover = true,
            completion = true,
          },
        },
      })

      -- Emmet for HTML/CSS super-fast expansion (popular in web-dev configs)
      vim.lsp.config("emmet_ls", {
        filetypes = {
          "html", "css", "scss", "javascript", "javascriptreact",
          "typescript", "typescriptreact", "vue", "svelte",
        },
      })

      -- LemMinX: XML Language Server with XSD & DTD validation
      -- Provides: completion, validation, hover, formatting for XML/XSD/DTD/XSLT
      vim.lsp.config("lemminx", {
        filetypes = { "xml", "xsd", "xsl", "xslt", "svg", "dtd" },
        settings = {
          xml = {
            validation = {
              enabled = true,
              schema = { enabled = "always" },
              -- Validate against referenced XSD schemas
              resolveExternalEntities = true,
              noGrammar = "hint",
            },
            format = {
              enabled = true,
              splitAttributes = true,
              joinCDATALines = false,
              joinCommentLines = false,
              formatComments = true,
              joinContentLines = false,
              spaceBeforeEmptyCloseTag = true,
              preserveEmptyContent = true,
            },
            completion = {
              autoCloseTags = true,
              autoCloseRemovesContent = true,
            },
            hover = {
              documentation = true,
            },
            -- File associations: map XML files to schemas
            -- Users can add project-specific associations here
            fileAssociations = {
              -- Example: { pattern = "pom.xml", systemId = "https://maven.apache.org/xsd/maven-4.0.0.xsd" },
              -- Example: { pattern = "web.xml", systemId = "https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd" },
              -- Example: { pattern = "*.xhtml", systemId = "http://www.w3.org/2002/08/xhtml/xhtml1-transitional.xsd" },
            },
            catalogs = {},
            logs = { client = false, file = vim.fn.stdpath("log") .. "/lemminx.log" },
          },
        },
      })

      vim.lsp.config("clangd", {
        capabilities = vim.tbl_deep_extend("force", capabilities, {
          offsetEncoding = { "utf-16" },
        }),
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
      })

      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" },
            inlayHints = {
              bindingModeHints = { enable = true },
              closureReturnTypeHints = { enable = "always" },
              lifetimeElisionHints = { enable = "always" },
            },
          },
        },
      })

      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            gofumpt = true,
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            analyses = {
              fieldalignment = true,
              nilness = true,
              unusedparams = true,
              unusedwrite = true,
              useany = true,
            },
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.venv", "-node_modules" },
            semanticTokens = true,
          },
        },
      })

      vim.lsp.config("ts_ls", {
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      })
    end,
  },
}
