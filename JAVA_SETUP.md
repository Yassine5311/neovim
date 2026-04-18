# Java/J2EE/Servlet/Tomcat Development in Neovim

## Quick Start

### Prerequisites
```bash
# Install Java (JDK 11+, preferably 17 or 21)
sudo apt install openjdk-21-jdk  # Ubuntu/Debian
# or
brew install openjdk@21           # macOS

# Set JAVA_HOME
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
# Add to ~/.bashrc or ~/.zshrc for persistence
```

### First Time Setup
Open Neovim and run:
```vim
:Mason
```
Then install:
- `jdtls` - Java Language Server
- `google-java-format` - Java formatter
- `debugpy` - Python debugger (for test debugging)

## Key Bindings

### LSP Navigation
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>cr` | Rename symbol |

### Java-Specific Navigation
| Key | Action |
|-----|--------|
| `gs` | Organize imports |
| `gx` | Open test class file |
| `<leader>jga` | Test class |
| `<leader>jgm` | Test nearest method |
| `<leader>jgd` | Pick delegate |
| `<leader>jgs` | Super implementation |
| `<leader>jgv` | Extract variable |

### Debugging
| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Set conditional breakpoint |
| `<leader>dc` | Continue |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>dO` | Step over |
| `<leader>dr` | Toggle REPL |
| `<leader>du` | Toggle DAP UI |
| `<leader>de` | Evaluate expression (visual mode) |

### Testing
| Key | Action |
|-----|--------|
| `<leader>tn` | Run nearest test |
| `<leader>tf` | Run file tests |
| `<leader>ta` | Run all tests |
| `<leader>ts` | Stop test |
| `<leader>tt` | Toggle test summary |
| `<leader>to` | Show test output |

## Maven Integration

### Prerequisites
```bash
# Install Maven
sudo apt install maven  # Ubuntu/Debian
# or
brew install maven      # macOS

# Verify installation
mvn --version
```

### Common Maven Commands (in Terminal)
```bash
# Build project
mvn clean compile

# Run tests
mvn test

# Package WAR for Tomcat
mvn clean package

# Run Tomcat (if maven-tomcat-plugin configured)
mvn tomcat7:run

# Skip tests
mvn clean package -DskipTests
```

### Configure pom.xml for Development
Add this to your `pom.xml` for easier J2EE development:

```xml
<properties>
  <maven.compiler.source>17</maven.compiler.source>
  <maven.compiler.target>17</maven.compiler.target>
  <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
</properties>

<dependencies>
  <!-- Jakarta EE (modern J2EE) -->
  <dependency>
    <groupId>jakarta.platform</groupId>
    <artifactId>jakarta.jakartaee-api</artifactId>
    <version>10.0.0</version>
    <scope>provided</scope>
  </dependency>
  
  <!-- Or if using legacy Java EE -->
  <dependency>
    <groupId>javax</groupId>
    <artifactId>javaee-api</artifactId>
    <version>8.0.1</version>
    <scope>provided</scope>
  </dependency>
</dependencies>

<build>
  <plugins>
    <!-- Compiler with debugging -->
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-compiler-plugin</artifactId>
      <version>3.11.0</version>
      <configuration>
        <source>17</source>
        <target>17</target>
        <debug>true</debug>
        <debuglevel>lines,vars,source</debuglevel>
      </configuration>
    </plugin>
    
    <!-- Tomcat 10 Plugin -->
    <plugin>
      <groupId>org.codehaus.mojo</groupId>
      <artifactId>tomcat-maven-plugin</artifactId>
      <version>1.1</version>
      <configuration>
        <url>http://localhost:8080/manager/html</url>
        <server>TomcatServer</server>
        <path>/myapp</path>
        <port>8080</port>
      </configuration>
    </plugin>
  </plugins>
</build>
```

## Debugging Tomcat

### Setup Remote Debugging
1. **Start Tomcat with debugging enabled:**
```bash
# In CATALINA_HOME/bin/catalina.sh or catalina.bat
# Add before the "start" section:
# CATALINA_OPTS="$CATALINA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000"
```

2. **In Neovim, set a breakpoint** (`<leader>db`)

3. **Start debugging:**
```vim
:DapContinue
```
Then select "Debug - Tomcat" from the menu

### Debug Maven Tests
1. Set breakpoint in test file
2. Run: `<leader>tn` or `<leader>tf`
3. Press `<leader>dc` to continue debug session

## Project Structure
```
my-j2ee-project/
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/
│   │   │       ├── servlet/
│   │   │       │   └── HelloServlet.java
│   │   │       └── controller/
│   │   │           └── UserController.java
│   │   └── webapp/
│   │       ├── WEB-INF/
│   │       │   ├── web.xml
│   │       │   └── lib/
│   │       └── index.jsp
│   └── test/
│       └── java/
│           └── com/example/
│               └── servlet/
│                   └── HelloServletTest.java
└── target/
    └── classes/
```

## Example Servlet Code

```java
package com.example.servlet;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/hello")
public class HelloServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html");
        response.getWriter().println("<h1>Hello from Neovim!</h1>");
    }
}
```

## Troubleshooting

### jdtls not starting
- Check if JDK 11+ is installed: `java -version`
- Set JAVA_HOME: `export JAVA_HOME=/path/to/jdk`
- Reinstall jdtls: `:Mason` → Find jdtls → `d` to uninstall → `i` to install

### Debugging not working
- Ensure port 5005 (or 8000 for Tomcat) is not in use: `lsof -i :5005`
- Check if breakpoint icons appear (● symbol)
- Look at `:Mason` logs for JAR conflicts

### Tomcat connection issues
- Verify Tomcat is running: `curl http://localhost:8080`
- Enable remote debugging in Tomcat startup
- Check firewall settings

### Slow JDTLS performance
- Increase heap memory in java.lua (currently 4GB `-Xmx4g`)
- Exclude large directories in `.project` file
- Disable unused features in settings

## Resources

- [JDTLS Documentation](https://github.com/eclipse/eclipse.jdt.ls)
- [Jakarta EE](https://jakarta.ee/)
- [Tomcat Documentation](https://tomcat.apache.org/)
- [Maven Handbook](https://maven.apache.org/guides/)

