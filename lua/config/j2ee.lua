local M = {}

local templates = {
  { label = "J2EE Web App (Servlet/JSP)", value = "simple" },
  { label = "JSP Web App (Servlet + JSP)", value = "simple" },
  { label = "Jakarta EE Web App", value = "jakarta-ee" },
  { label = "REST API (Jakarta REST)", value = "rest-api" },
  { label = "Spring Boot Web App", value = "spring-boot" },
}

local function open_browser(url)
  local ok = vim.fn.executable("xdg-open") == 1
  if ok then
    vim.fn.jobstart({ "xdg-open", url }, { detach = true })
    vim.notify("Opening browser: " .. url, vim.log.levels.INFO)
    return
  end
  vim.notify("xdg-open not found. Open manually: " .. url, vim.log.levels.WARN)
end

local function run_in_split(cmd, cwd, on_exit_cb)
  vim.cmd("botright 12split")
  local opts = { cwd = cwd or vim.fn.getcwd() }
  if on_exit_cb then
    opts.on_exit = on_exit_cb
  end
  vim.fn.termopen({ "bash", "-lc", cmd }, opts)
  vim.cmd("startinsert")
end

function M.create_project()
  local script = vim.fn.stdpath("config") .. "/java-workspace/scaffold-project.sh"

  if vim.fn.filereadable(script) == 0 then
    vim.notify("Project scaffold script not found: " .. script, vim.log.levels.ERROR)
    return
  end

  vim.ui.input({ prompt = "Project name: " }, function(project_name)
    if not project_name or project_name == "" then return end

    vim.ui.select(templates, {
      prompt = "Project template:",
      format_item = function(item) return item.label end,
    }, function(template)
      if not template then return end

      vim.ui.input({
        prompt = "Destination folder: ",
        default = vim.fn.getcwd(),
      }, function(dest)
        if not dest or dest == "" then return end
        vim.fn.mkdir(dest, "p")

        local target_dir = dest .. "/" .. project_name
        local cmd = string.format("'%s' '%s' '%s'", script, project_name, template.value)

        run_in_split(cmd, dest, function(_, code)
          if code == 0 then
            vim.schedule(function()
              vim.cmd("cd " .. vim.fn.fnameescape(target_dir))
              pcall(function() vim.cmd("NvimTreeFocus") end)
              vim.notify("Created and opened project in " .. target_dir, vim.log.levels.INFO)
            end)
          end
        end)
      end)
    end)
  end)
end

function M.open_project()
  vim.ui.input({ prompt = "Open Project (Path): ", completion = "dir", default = vim.fn.getcwd() .. "/" }, function(path)
    if not path or path == "" then return end
    if vim.fn.isdirectory(path) == 1 then
      vim.cmd("cd " .. vim.fn.fnameescape(path))
      pcall(function() vim.cmd("NvimTreeFocus") end)
      vim.notify("Switched to project: " .. path, vim.log.levels.INFO)
    else
      vim.notify("Directory does not exist: " .. path, vim.log.levels.ERROR)
    end
  end)
end

function M.debug_build_deploy()
  local cwd = vim.fn.getcwd()
  local setup_script = vim.fn.stdpath("config") .. "/java-workspace/tomcat10-setup.sh"

  if vim.fn.filereadable(cwd .. "/pom.xml") == 0 then
    vim.notify("No pom.xml found in current directory", vim.log.levels.ERROR)
    return
  end
  if vim.fn.filereadable(setup_script) == 0 then
    vim.notify("Tomcat setup script not found: " .. setup_script, vim.log.levels.ERROR)
    return
  end

  local cmd = table.concat({
    "mvn -DskipTests clean package",
    "&&",
    setup_script .. " start-debug",
    "&&",
    setup_script .. " deploy target/*.war",
  }, " ")

  run_in_split(cmd, cwd, function(_, code)
    if code == 0 then
      vim.schedule(function()
        vim.notify("Build and deploy complete! Attaching debugger...", vim.log.levels.INFO)
        local has_dap, dap = pcall(require, "dap")
        if has_dap then
           -- Auto-attach to Tomcat's default debug port in the background
           dap.run({
             name = "Tomcat Auto-Attach",
             type = "java",
             request = "attach",
             hostName = "localhost",
             port = 8000,
           })
        end
      end)
    else
      vim.schedule(function()
        vim.notify("Build or start failed.", vim.log.levels.ERROR)
      end)
    end
  end)
  vim.notify("Build + debug + deploy started", vim.log.levels.INFO)
end

function M.open_project_browser()
  vim.ui.input({ prompt = "URL: ", default = "http://localhost:8080/" }, function(url)
    if not url or url == "" then return end
    open_browser(url)
  end)
end

function M.menu()
  local actions = {
    { label = "Create new J2EE/JSP project", fn = M.create_project },
    { label = "Open existing project", fn = M.open_project },
    { label = "Build + Start Tomcat + Debug (DAP)", fn = M.debug_build_deploy },
    { label = "Open Browser URL", fn = M.open_project_browser },
  }

  vim.ui.select(actions, {
    prompt = "J2EE Menu:",
    format_item = function(item) return item.label end,
  }, function(choice)
    if not choice then return end
    choice.fn()
  end)
end

return M
