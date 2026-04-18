-- Enhanced Tomcat & Java Debugging Configuration
-- Place this in your Neovim config or load it in java.lua
-- Extends nvim-dap with improved debugging configurations

local dap = require("dap")

-- Enhanced Tomcat debugging configuration
dap.configurations.java = {
  -- Standard Maven build + local debugging
  {
    name = "Debug (Attach) - Maven Local",
    type = "java",
    request = "attach",
    hostName = "localhost",
    port = 5005,
    preLaunchTask = "Java: Build (Maven)",
    skipFiles = { "<rt jar>", "*/node_modules/**" },
    stopOnEntry = false,
    logOutput = "console",
    trace = {
      all = false,
      console = false,
      mode = "verbose",
    },
  },

  -- Tomcat local debugging (port 8000)
  {
    name = "Debug - Tomcat (Local Port 8080)",
    type = "java",
    request = "attach",
    hostName = "localhost",
    port = 8000,
    preLaunchTask = "Tomcat: Run with Debugging (Port 8080, Debug 8000)",
    skipFiles = { "<rt jar>", "*/node_modules/**" },
    stopOnEntry = false,
    shortenPathlen = 40,
    consoleDebuggingOutputType = "vscode",
  },

  -- Remote Tomcat debugging (production/remote server)
  {
    name = "Debug - Remote Tomcat (Port 8000)",
    type = "java",
    request = "attach",
    hostName = function() return vim.fn.input("Remote host (localhost): ", "localhost") end,
    port = function() return tonumber(vim.fn.input("Remote debug port (8000): ", "8000")) end,
    skipFiles = { "<rt jar>", "*/node_modules/**" },
    stopOnEntry = false,
    cwd = "${workspaceFolder}",
  },

  -- Maven Surefire test debugging
  {
    name = "Debug - Maven Test (Surefire)",
    type = "java",
    request = "launch",
    cwd = "${workspaceFolder}",
    console = "integratedTerminal",
    mainClass = "org.apache.maven.surefire.booter.ForkedBooter",
    args = function() 
      return vim.fn.split(vim.fn.system("mvn help:describe -Dplugin=org.apache.maven.plugins:maven-surefire-plugin"), "\n")
    end,
    stopOnEntry = false,
    skipFiles = { "<rt jar>", "*/node_modules/**" },
  },

  -- Single JUnit test debugging
  {
    name = "Debug - Current Test File",
    type = "java",
    request = "launch",
    cwd = "${workspaceFolder}",
    console = "integratedTerminal",
    mainClass = "org.junit.platform.console.ConsoleLauncher",
    args = {
      "--scan-classpath",
      "--class-path=target/test-classes:target/classes",
    },
    stopOnEntry = false,
  },

  -- Application main class debugging
  {
    name = "Debug - Main Class",
    type = "java",
    request = "launch",
    cwd = "${workspaceFolder}",
    console = "integratedTerminal",
    mainClass = function() return vim.fn.input("Main class (com.example.Main): ", "") end,
    projectName = function() return vim.fn.fnamemodify(vim.fn.getcwd(), ":t") end,
    stopOnEntry = false,
    args = function() return vim.fn.split(vim.fn.input("Program arguments: ", ""), " ") end,
  },
}

-- Exception breakpoints typically require an active session,
-- you can set them during a session via `dap.set_exception_breakpoints()`
-- dap.set_exception_breakpoints({ "all" })

-- Enhanced breakpoint handling
vim.fn.sign_define("DapBreakpoint", {
  text = "●",
  texthl = "ErrorMsg",
  linehl = "DapBreakpointLine",
  numhl = "DapBreakpointNum",
})
vim.fn.sign_define("DapLogPoint", {
  text = "◆",
  texthl = "WarningMsg",
  linehl = "DapLogPointLine",
  numhl = "DapLogPointNum",
})
vim.fn.sign_define("DapStopped", {
  text = "▶",
  texthl = "Function",
  linehl = "DapStoppedLine",
  numhl = "DapStoppedNum",
})

-- DAP event listeners
dap.listeners.after.event_initialized["enhance_tomcat"] = function()
  require("dapui").open()
  vim.notify("Debug session started", vim.log.levels.INFO)
end

dap.listeners.before.event_terminated["enhance_tomcat"] = function()
  require("dapui").close()
end

dap.listeners.before.event_exited["enhance_tomcat"] = function()
  require("dapui").close()
end

-- Show variable value on hover during debugging
local function run_debug_command(cmd)
  return function()
    if dap.session() then
      vim.cmd(":DapUIEval " .. cmd)
    else
      vim.notify("No debug session active", vim.log.levels.WARN)
    end
  end
end

-- Additional keymaps for debugging
local keymap_opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>dee", run_debug_command("vim.fn.expand('<cword>')"), keymap_opts)
vim.keymap.set("v", "<leader>dee", function()
  local text = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))
  if dap.session() then
    vim.cmd(":DapUIEval " .. table.concat(text, " "))
  end
end, keymap_opts)

-- Clear all breakpoints helper
vim.keymap.set("n", "<leader>dbc", function()
  dap.clear_breakpoints()
  vim.notify("All breakpoints cleared", vim.log.levels.INFO)
end, { desc = "Clear all breakpoints" })

-- List all breakpoints
vim.keymap.set("n", "<leader>dbl", function()
  local breakpoints = dap.list_breakpoints()
  if #breakpoints == 0 then
    vim.notify("No breakpoints set", vim.log.levels.INFO)
    return
  end

  local lines = { "=== Breakpoints ===" }
  for idx, bp in ipairs(breakpoints) do
    table.insert(lines, string.format("%d. %s:%d", idx, vim.fn.fnamemodify(bp.file, ":~"), bp.line))
    if bp.condition then
      table.insert(lines, "   └─ Condition: " .. bp.condition)
    end
  end

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end, { desc = "List all breakpoints" })

return {}
