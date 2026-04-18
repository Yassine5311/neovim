-- ── Java Development Tools ────────────────────────────────
-- Complete J2EE/Servlet support with Maven, Tomcat debugging
return {
  -- nvim-jdtls: Extended Java Language Server integration
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    dependencies = { "neovim/nvim-lspconfig", "mfussenegger/nvim-dap" },
    config = function()
      local jdtls = require("jdtls")
      local home = os.getenv("HOME")
      local workspace_dir = vim.fn.stdpath("data") .. "/jdtls_workspace"

      -- Detect Java version and runtime
      local function get_jdk_path()
        -- Try to find JAVA_HOME
        local java_home = os.getenv("JAVA_HOME")
        if java_home and java_home ~= "" then
          return java_home
        end
        -- Fallback: search for common Java installation paths
        local paths = {
          "/usr/lib/jvm/java-21-openjdk",
          "/usr/lib/jvm/java-17-openjdk",
          "/usr/lib/jvm/java-11-openjdk",
          "/opt/openjdk",
          "/Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home",
        }
        for _, path in ipairs(paths) do
          if vim.fn.isdirectory(path) == 1 then
            return path
          end
        end
        return nil
      end

      local jdk_path = get_jdk_path()
      if not jdk_path then
        vim.notify(
          "⚠️ JAVA_HOME not set and no JDK found. Please install a JDK and set JAVA_HOME.",
          vim.log.levels.WARN
        )
        return
      end

      -- JDTLS setup with increased memory for J2EE projects
      local config = {
        cmd = {
          jdk_path .. "/bin/java",
          "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.level=OFF",
          "-noverify",
          "-Xmx4g", -- Increased heap for large J2EE projects
          "-XX:+UseG1GC",
          "-XX:+UseStringDeduplication",
          "-javaagent:" .. home .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar",
          "--add-modules=ALL-SYSTEM",
          "--add-opens",
          "java.base/java.util=ALL-UNNAMED",
          "--add-opens",
          "java.base/java.lang=ALL-UNNAMED",
          "-jar",
          home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar",
          "-configuration",
          home .. "/.local/share/nvim/mason/packages/jdtls/config_linux",
          "-data",
          workspace_dir,
        },
        root_dir = require("lspconfig.util").root_pattern({ ".git", "pom.xml", "build.gradle", ".project" }),
        settings = {
          java = {
            home = jdk_path,
            eclipse = {
              downloadSources = true,
              updateBuildConfiguration = "interactive",
            },
            configuration = {
              updateBuildConfiguration = "interactive",
              runtimes = {
                {
                  name = "JavaSE",
                  path = jdk_path,
                  default = true,
                },
              },
            },
            maven = {
              downloadSources = true,
              updateBuildConfiguration = "interactive",
            },
            implementationsCodeLens = {
              enabled = true,
              codeLensMode = "new",
            },
            referencesCodeLens = {
              enabled = true,
            },
            codeGeneration = {
              hashCodeEquals = {
                useJava7Objects = true,
              },
              useBlocks = true,
              toString = {
                template = "${object}.toString()",
                codeStyle = "STRING_CONCATENATION",
                skipNullValues = false,
                listSize = 5,
              },
              generateComments = true,
            },
            sources = {
              organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
              },
            },
            saveActions = {
              organizeImports = true,
              formatOnSave = true,
            },
            signatureHelp = {
              description = {
                enabled = true,
              },
            },
            contentProvider = "fernflower",
            autobuild = {
              enabled = true,
            },
            maxConcurrentBuilds = 4,
            completion = {
              maxResults = 20,
              matchCase = "off",
              favoriteStaticMembers = {
                "org.junit.Assert.*",
                "org.junit.Assume.*",
                "org.junit.jupiter.api.Assertions.*",
                "org.junit.jupiter.api.Assumptions.*",
                "org.junit.jupiter.api.DynamicContainer.*",
                "org.junit.jupiter.api.DynamicTest.*",
                "org.mockito.Mockito.*",
              },
              filteredTypes = {
                "java.awt.*",
                "com.sun.*",
                "sun.*",
                "**/internal/*",
              },
            },
            jdt = {
              ls = {
                vmargs = "-XX:+UseG1GC -XX:+UseStringDeduplication -Xmx4g",
              },
            },
          },
        },
        init_options = {
          bundles = {},
        },
      }

      -- Include debugging Java file extensions
      local extendedClientCapabilities = jdtls.extendedClientCapabilities
      extendedClientCapabilities.resolveCodeAction = true
      extendedClientCapabilities.classFileContentsSupport = true

      config.capabilities = vim.lsp.protocol.make_client_capabilities()
      config.capabilities = require("cmp_nvim_lsp").default_capabilities(config.capabilities)
      config.extendedClientCapabilities = extendedClientCapabilities

      -- Setup jdtls with keymaps
      config.on_attach = function(client, bufnr)
        -- Default LSP keymaps already set up in lsp.lua via LspAttach
        jdtls.setup_dap({ hotcodereplace = "auto" })

        -- Java-specific keymaps
        local map = function(keys, func, desc, mode)
          mode = mode or "n"
          vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "JDTLS: " .. desc })
        end

        -- Code generation & navigation
        map("gs", jdtls.organize_imports, "Organize imports")
        map("gx", jdtls.open_javatest_classfile, "Open test class file")
        map("<leader>jga", jdtls.test_class, "Test class")
        map("<leader>jgm", jdtls.test_nearest_method, "Test nearest method")
        map("<leader>jgd", jdtls.pick_delegate, "Pick delegate")
        map("<leader>jgs", jdtls.super_implementation, "Show super implementation")
        map("<leader>jgv", jdtls.extract_variable, "Extract variable", { "n", "v" })
        map("<leader>jgm", jdtls.extract_method, "Extract method", { "v" })
      end

      -- Start JDTLS
      jdtls.start_or_attach(config)

      -- Auto-reload on project file changes
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = vim.api.nvim_create_augroup("java_reload", { clear = true }),
        pattern = { "*.java", "pom.xml", "build.gradle" },
        callback = function()
          vim.lsp.buf.format({ timeout_ms = 2000 })
        end,
      })
    end,
  },

  -- nvim-dap: Debugging Protocol adapter
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Set conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to cursor" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "Go to line" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>dj", function() require("dap").down() end, desc = "Down stack frame" },
      { "<leader>dk", function() require("dap").up() end, desc = "Up stack frame" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Hover" },
    },
    config = function()
      local dap = require("dap")

      -- Java debug adapter (uses JDTLS built-in debugging)
      dap.configurations.java = {
        {
          name = "Debug (Attach) - Local",
          type = "java",
          request = "attach",
          hostName = "localhost",
          port = 5005,
          preLaunchTask = "tasks: run maven build",
        },
        {
          name = "Debug (Launch) - Current File",
          type = "java",
          request = "launch",
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
        },
        {
          name = "Debug - Tomcat",
          type = "java",
          request = "attach",
          hostName = "localhost",
          port = 8000,
          preLaunchTask = "tomcat: start",
        },
        {
          name = "Debug - Maven Test",
          type = "java",
          request = "launch",
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
          mainClass = "org.apache.maven.surefire.booter.ForkedBooter",
          args = "${workspaceFolder}",
        },
      }

      -- Generic debug adapter (for other configurations)
      if not dap.adapters.java then
        dap.adapters.java = function(callback, config)
          callback({
            type = "executable",
            command = "java",
            args = {
              "-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005",
              "-cp",
              "${workspaceFolder}/target/classes:${workspaceFolder}/target/test-classes",
              config.mainClass or "Main",
            },
          })
        end
      end

      -- Highlights
      vim.fn.sign_define("DapBreakpoint", { text = "● ", texthl = "DapBreakpoint", linehl = "DapBreakpointLine", numhl = "DapBreakpointNum" })
      vim.fn.sign_define("DapStopped", { text = "▶ ", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "DapStoppedNum" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "✗ ", texthl = "DapBreakpointRejected", numhl = "DapBreakpointRejectedNum" })
      vim.fn.sign_define("DapLogPoint", { text = "◆ ", texthl = "DapLogPoint", linehl = "", numhl = "" })

      -- DAP listeners
      dap.listeners.after.event_initialized["dapui_config"] = function()
        require("dapui").open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        require("dapui").close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        require("dapui").close()
      end
    end,
  },

  -- nvim-dap-ui: UI for debugging
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    keys = {
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Evaluate expression" },
    },
    config = function()
      local dapui = require("dapui")
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸" },
        mappings = {
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        expand_lines = vim.fn.has("nvim-0.10") == 1,
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.33 },
              { id = "breakpoints", size = 0.17 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 10,
            position = "bottom",
          },
        },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "↻",
            terminate = "□",
            disconnect = "⏹",
          },
        },
        floating = {
          max_height = nil, -- These can be integers or a float between 0 and 1.
          max_width = nil, -- Floats will be treated as percentage of your screen.
          border = "rounded",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil, -- Can be integer or nil.
          max_value_length = nil,
          indent = 1,
        },
      })
    end,
  },

  -- nvim-neotest: Test runner for JUnit tests
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
    },
    keys = {
      { "<leader>tn", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
      { "<leader>ta", function() require("neotest").run.run({ suite = true }) end, desc = "Run all tests" },
      { "<leader>ts", function() require("neotest").run.stop() end, desc = "Stop test" },
      { "<leader>tt", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Show test output" },
    },
    config = function()
      local neotest_ok, neotest = pcall(require, "neotest")
      if not neotest_ok then return end
      -- Java testing via jdtls test discovery
      -- For unit tests, use Maven from command line or IDE shortcuts
      neotest.setup({
        adapters = {
          -- Extend with Java adapter if available
          -- require("neotest-java")(),
        },
      })
    end,
  },
}
