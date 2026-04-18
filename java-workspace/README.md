# J2EE Workspace Improvements

This directory contains enhanced tools and templates for J2EE development with Neovim.

## Contents

### 1. **scaffold-project.sh** - Project Generator
Creates a new J2EE project with proper Maven structure and configuration.

**Usage:**
```bash
chmod +x scaffold-project.sh
./scaffold-project.sh my-app simple
./scaffold-project.sh my-api rest-api
./scaffold-project.sh my-boot spring-boot
./scaffold-project.sh my-jakarta jakarta-ee
```

**Templates:**
- `simple` - Basic servlet/JSP application
- `rest-api` - RESTful API with Jakarta REST
- `spring-boot` - Spring Boot web application
- `jakarta-ee` - Modern Jakarta EE application

### 2. **tasks.json** - VS Code Tasks
Maven and Tomcat build/run tasks for Neovim's Telescope integration.

**Usage in Neovim:**
Copy to `.vscode/tasks.json` or run via:
```vim
:!npm run task:build
:!npm run task:test
```

**Key Tasks:**
- `Java: Build (Maven)` - Compile source code
- `Java: Test (Maven)` - Run unit tests
- `Tomcat: Run Local` - Start Tomcat with app
- `Tomcat: Run with Debugging` - Debug mode (port 8000)
- `Docker: Build Image` - Build Docker image
- `Docker Compose: Up` - Start full stack

### 3. **snippets/java-j2ee.json** - Code Snippets
Reusable code templates for common J2EE patterns.

**Available Snippets:**
- `servlet` - HttpServlet implementation (type: `servlet<Tab>`)
- `rest-resource` - REST endpoint with CRUD methods
- `filter` - Servlet filter implementation
- `listener` - Context/session listener

### 4. **Dockerfile** - Container Image
Build a production-ready Tomcat image with your J2EE app.

```bash
# Build image
docker build -t my-j2ee-app:latest .

# Run container
docker run -p 8080:8080 -p 8000:8000 my-j2ee-app:latest
```

**Features:**
- Multi-stage build (optimized image size)
- Remote debugging support (port 8000)
- Health checks included
- Alpine Linux (lightweight)

### 5. **docker-compose.yml** - Full Stack
Complete development environment with Tomcat, PostgreSQL, and pgAdmin.

```bash
docker-compose up -d
# Access:
# - Tomcat: http://localhost:8080/app
# - PostgreSQL: localhost:5432
# - pgAdmin: http://localhost:5050
```

### 6. **tomcat-debug-config.lua** - Debug Setup
Enhanced debugging configuration for nvim-dap.

**Features:**
- Tomcat attachment debugging
- Maven test debugging
- Remote debugging support
- Breakpoint visualization
- Variable inspection

## Workflow

### Quick Start
```bash
# Create project
./scaffold-project.sh myapp rest-api

# Build
cd myapp
mvn clean compile

# Run with debugging in Neovim
# 1. Copy tasks.json to .vscode/tasks.json
# 2. In Neovim: <leader>db to set breakpoint
# 3. :DapContinue to start debugging
# 4. Choose "Debug - Tomcat (Local Port 8080)"
```

### Development Cycle
1. **Edit code** in Neovim
2. **Build**: `mvn clean compile`
3. **Test**: `mvn test` or `<leader>tn` in Neovim
4. **Debug**: Set breakpoint with `<leader>db`, run with `<leader>dc`
5. **Run**: `mvn tomcat7:run` for local testing

### Docker Development
```bash
# Development with hot-reload
docker-compose up -d

# Watch logs
docker-compose logs -f tomcat

# Deploy new version
mvn clean package
docker-compose restart tomcat
```

## Configuration Files

### For New Projects (inside each project):

**.vscode/settings.json** - VS Code Java settings
```json
{
  "java.format.settings.url": "${workspaceFolder}/eclipse-formatter.xml",
  "[java]": {
    "editor.defaultFormatter": "redhat.java",
    "editor.formatOnSave": true
  }
}
```

**.vscode/launch.json** - Debug configurations (if using VS Code)
```json
{
  "configurations": [
    {
      "name": "Attach to Tomcat",
      "type": "java",
      "request": "attach",
      "hostName": "localhost",
      "port": 8000
    }
  ]
}
```

## Integration with Neovim

### Copy snippets to Neovim
```bash
cp snippets/java-j2ee.json ~/.config/nvim/snippets/
```

### Copy tasks to project
```bash
mkdir -p .vscode
cp tasks.json .vscode/
```

### Copy debug config to lua/plugins/
```bash
cp tomcat-debug-config.lua ~/.config/nvim/lua/plugins/java-debug.lua
```

## Environment Setup

### Prerequisites
```bash
# Java Development Kit
java -version

# Maven
mvn --version

# Docker (optional)
docker --version
docker-compose --version
```

### JAVA_HOME Configuration
```bash
# Verify JAVA_HOME is set
echo $JAVA_HOME

# If not set, add to ~/.bashrc or ~/.zshrc
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
```

## Troubleshooting

### JDTLS not finding classes
- Run `mvn clean compile` first
- Ensure `.classpath` is properly configured
- Clear JDTLS cache: `rm -rf ~/.cache/nvim/jdtls`

### Debugging not connecting
- Check port is free: `lsof -i :8000`
- Ensure Tomcat started with `-agentlib:jdwp`
- Verify `<leader>db` created breakpoint icon (●)

### Docker build fails
- Build locally first: `mvn clean package`
- Check Docker daemon is running
- Ensure Dockerfile is in project root

## Resources

- [JDTLS](https://github.com/eclipse/eclipse.jdt.ls)
- [Tomcat Documentation](https://tomcat.apache.org/)
- [Maven Guide](https://maven.apache.org/guides/)
- [Jakarta EE](https://jakarta.ee/)
- [Docker Compose Docs](https://docs.docker.com/compose/)

