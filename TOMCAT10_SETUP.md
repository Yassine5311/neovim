# Tomcat 10 Setup Guide for Neovim J2EE Development

## Installation Confirmed
✅ **Tomcat 10** installed at `/usr/share/tomcat10`
✅ **CATALINA_HOME** exported in `~/.config/fish/config.fish`
✅ **Debugging configured** on port 8000
✅ **Maven support** via tomcat10-maven-plugin v2.3

## Quick Start

### 1. Set up environment variables
```bash
export CATALINA_HOME=/usr/share/tomcat10
export CATALINA_BASE=~/.local/share/tomcat10 # or use custom directory
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
```

### 2. Start Tomcat with debugging
```bash
# Method 1: Using helper script (recommended)
~/.config/nvim/java-workspace/tomcat10-setup.sh start-debug
# Remote debug available on localhost:8000

# Method 2: Manual start
export CATALINA_OPTS="-Xmx2g -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000"
/usr/share/tomcat10/bin/catalina.sh jpda start
```

### 3. Stop Tomcat
```bash
~/.config/nvim/java-workspace/tomcat10-setup.sh stop
# OR
/usr/share/tomcat10/bin/catalina.sh stop
```

## Creating J2EE Projects for Tomcat 10

### Via Dashboard (Neovim)
1. Press `p` to open project creation menu
2. Select "J2EE Web App"
3. Enter project name (e.g., `my-app`)
4. Project auto-generated with `tomcat10-maven-plugin` configured

### Via Terminal
```bash
~/.config/nvim/java-workspace/scaffold-project.sh my-app j2ee
cd my-app
```

## Build and Run

### Maven-based (recommended)
```bash
# Compile
mvn clean compile

# Run tests
mvn test

# Package as WAR
mvn clean package

# Deploy WAR to running Tomcat
~/.config/nvim/java-workspace/tomcat10-setup.sh deploy target/*.war
```

### Direct deployment
```bash
# If Tomcat is running
~/.config/nvim/java-workspace/tomcat10-setup.sh deploy target/*.war
```

## Remote Debugging in Neovim

### 1. Start Tomcat with debugging
```bash
~/.config/nvim/java-workspace/tomcat10-setup.sh start-debug
```

### 2. Set breakpoints in Neovim
- Open `.java` file in Neovim
- Place cursor on line
- Press `<leader>db` (or use DAP UI)
- Breakpoint marked with ●

### 3. Trigger request
```bash
curl http://localhost:8080/my-app/hello
```

### 4. Debug in Neovim
- Step through code: `<leader>dc` (continue), `<leader>dn` (next), `<leader>di` (step in)
- Inspect variables in DAP UI sidebar
- Type expressions in REPL

## Maven Plugin Configuration

### Local Tomcat Maven Plugin Details
- **GroupId**: `org.codehaus.mojo`
- **ArtifactId**: `tomcat-maven-plugin`
- **Version**: `1.1`

### Build plugin block (auto-included in scaffolded projects)
```xml
<plugin>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>tomcat-maven-plugin</artifactId>
    <version>1.1</version>
</plugin>
```

## Troubleshooting

### Tomcat won't start
```bash
# Check configuration
/usr/share/tomcat10/bin/configtest.sh

# Check logs
cat ~/.local/share/tomcat10/logs/catalina.out
# OR with helper script
~/.config/nvim/java-workspace/tomcat10-setup.sh logs
```

### Port 8000 already in use (debugging)
```bash
# Kill existing process
lsof -i :8000
kill -9 <PID>

# Or use different port
export CATALINA_OPTS="... -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8001"
```

### Maven can't find tomcat10 goal
```bash
# This is expected: there is no Maven goal named tomcat10:run
# Use package + deploy workflow instead
mvn clean package
~/.config/nvim/java-workspace/tomcat10-setup.sh deploy target/*.war
```

### App URL after deploy
- WAR name `my-app-1.0.0.war` maps to `http://localhost:8080/my-app-1.0.0`
- To deploy at root path, rename WAR to `ROOT.war` before deploying

### Breakpoints not working in debugger
- Verify `<searchPaths>` in Neovim's DAP config points to project

## All 4 Templates Updated for Tomcat 10 Deployment

✅ **simple** (j2ee)  
✅ **spring-boot**  
✅ **jakarta-ee**  
✅ **rest-api**  

All generate WAR-ready projects for local Tomcat 10 deployment

## Key Differences: Tomcat 10 vs Tomcat 7

| Feature | Tomcat 7 | Tomcat 10 |
|---------|----------|----------|
| **Java** | 6+ | 11+ |
| **Servlet API** | javax.servlet.* | jakarta.servlet.* |
| **Maven Plugin** | tomcat7-maven-plugin | tomcat10-maven-plugin |
| **HTTP/2 Support** | No | Yes |
| **Virtual Threads** | No | Java 21+ compatible |

## Configuration Files

- **Startup script**: `~/.config/nvim/java-workspace/tomcat10-setup.sh`
- **Scaffold templates**: `~/.config/nvim/java-workspace/scaffold-project.sh` (all 4 templates updated)
- **pom.xml template**: `~/.config/nvim/pom-template.xml` (Tomcat 10 plugin)
- **Neovim Java IDE**: `~/.config/nvim/lua/plugins/java.lua` (DAP + JDTLS)

## Next Steps

1. ✅ Tomcat 10 installed
2. ✅ CATALINA_HOME configured  
3. ✅ Maven plugin updated (tomcat10-maven-plugin v2.3)
4. 📝 Create first J2EE project: `~/.config/nvim/java-workspace/scaffold-project.sh my-first-app j2ee`
5. 🚀 Start Tomcat: `~/.config/nvim/java-workspace/tomcat10-setup.sh start-debug`
6. 🔍 Debug in Neovim with remote debugger on port 8000
