#!/bin/bash
# J2EE Project Scaffolding Script
# Creates a new J2EE project with proper structure and configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() { echo -e "${BLUE}ℹ${NC} $*"; }
print_success() { echo -e "${GREEN}✓${NC} $*"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $*"; }
print_error() { echo -e "${RED}✗${NC} $*"; }

normalize_template() {
    case "$1" in
        j2ee|j2ee-web)
            echo "simple"
            ;;
        *)
            echo "$1"
            ;;
    esac
}

main() {
    # Check if project name is provided
    if [ -z "$1" ]; then
        print_error "Usage: ./scaffold-project.sh <project-name> [template]"
        echo ""
        echo "Templates:"
        echo "  - simple       : Basic servlet/JSP project"
        echo "  - j2ee         : Alias of simple"
        echo "  - spring-boot  : Spring Boot web application"
        echo "  - jakarta-ee   : Jakarta EE (modern J2EE) application"
        echo "  - rest-api     : RESTful API with Jakarta REST"
        exit 1
    fi

    PROJECT_NAME=$1
    TEMPLATE=$(normalize_template "${2:-simple}")
    PROJECT_DIR=$(pwd)/$PROJECT_NAME
    # Convert spaces to underscores and hyphens to underscores for valid Java package names
    SAFE_NAME="${PROJECT_NAME// /_}"
    SAFE_NAME="${SAFE_NAME//-/_}"
    JAVA_PACKAGE="com.example.${SAFE_NAME}"

    print_info "Creating J2EE project: $PROJECT_NAME"
    print_info "Template: $TEMPLATE"
    print_info "Package: $JAVA_PACKAGE"

    # Create directory structure
    mkdir -p "$PROJECT_DIR"/{src/main/java,src/main/webapp/WEB-INF,src/test/java,src/test/resources}
    mkdir -p "$PROJECT_DIR"/{target,.vscode}

    print_success "Created project directory structure"

    # Create package directory
    PACKAGE_DIR="$PROJECT_DIR/src/main/java/${JAVA_PACKAGE//./\/}"
    mkdir -p "$PACKAGE_DIR"
    mkdir -p "$PROJECT_DIR/src/test/java/${JAVA_PACKAGE//./\/}"

    # Create appropriate pom.xml based on template
    case $TEMPLATE in
        simple)
            create_simple_pom
            ;;
        spring-boot)
            create_springboot_pom
            ;;
        jakarta-ee)
            create_jakarta_pom
            ;;
        rest-api)
            create_rest_api_pom
            ;;
        *)
            print_error "Unknown template: $TEMPLATE"
            exit 1
            ;;
    esac

    # Create web.xml
    create_web_xml

    # Create README
    create_readme

    # Create JDTLS configuration
    create_jdtls_config

    # Create VS Code workspace settings
    create_vscode_settings

    # Create sample servlet or controller
    case $TEMPLATE in
        simple)
            create_sample_servlet
            create_jsp_page
            ;;
        spring-boot)
            create_spring_boot_app
            ;;
        jakarta-ee)
            create_jakarta_app
            create_jsp_page
            ;;
        rest-api)
            create_rest_endpoint
            ;;
    esac

    # Create test class
    create_test_class

    print_success "Project scaffolding complete!"
    echo ""
    echo "📁 Project structure:"
    tree -L 3 "$PROJECT_DIR" 2>/dev/null || find "$PROJECT_DIR" -type f | head -20
    echo ""
    echo "🚀 Next steps:"
    echo "  cd $PROJECT_NAME"
    echo "  mvn clean compile"
    echo "  mvn test"
    if [ "$TEMPLATE" = "spring-boot" ]; then
        echo "  mvn spring-boot:run"
    else
        echo "  mvn clean package"
        echo "  ~/.config/nvim/java-workspace/tomcat10-setup.sh deploy target/*.war"
        echo "  open http://localhost:8080/$PROJECT_NAME/hello"
    fi
    echo ""
    echo "🔗 Open in Neovim:"
    echo "  nvim ."
    echo ""
}

# ============ Template Functions ============

create_simple_pom() {
    cat > "$PROJECT_DIR/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>PROJECT_NAME</artifactId>
    <version>1.0.0</version>
    <packaging>war</packaging>

    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <jakarta-servlet.version>6.0.0</jakarta-servlet.version>
        <junit.version>5.10.0</junit.version>
    </properties>

    <dependencies>
        <!-- Jakarta Servlet API -->
        <dependency>
            <groupId>jakarta.servlet</groupId>
            <artifactId>jakarta.servlet-api</artifactId>
            <version>${jakarta-servlet.version}</version>
            <scope>provided</scope>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>${junit.version}</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <finalName>PROJECT_NAME</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
                <configuration>
                    <source>17</source>
                    <target>17</target>
                    <debug>true</debug>
                </configuration>
            </plugin>

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <version>3.4.0</version>
            </plugin>

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.1.2</version>
            </plugin>

            <!-- Tomcat Plugin -->
            <plugin>
                <groupId>org.codehaus.mojo</groupId>
                <artifactId>tomcat-maven-plugin</artifactId>
                <version>1.1</version>
                <configuration>
                    <path>/app</path>
                    <port>8080</port>
                </configuration>
            </plugin>
        </plugins>

    </build>
</project>
EOF
    sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/pom.xml"
    print_success "Created pom.xml (simple template)"
}

create_springboot_pom() {
    cat > "$PROJECT_DIR/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>PROJECT_NAME</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>

    <properties>
        <java.version>17</java.version>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
    </properties>

    <dependencies>
        <!-- Spring Boot Web -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- Spring Boot Test -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>

    </build>
</project>
EOF
    sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/pom.xml"
    print_success "Created pom.xml (Spring Boot template)"
}

create_jakarta_pom() {
    cat > "$PROJECT_DIR/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>PROJECT_NAME</artifactId>
    <version>1.0.0</version>
    <packaging>war</packaging>

    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <jakarta-ee.version>10.0.0</jakarta-ee.version>
    </properties>

    <dependencies>
        <!-- Jakarta EE Full Platform -->
        <dependency>
            <groupId>jakarta.platform</groupId>
            <artifactId>jakarta.jakartaee-api</artifactId>
            <version>${jakarta-ee.version}</version>
            <scope>provided</scope>
        </dependency>

        <!-- JUnit 5 -->
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.10.0</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <finalName>PROJECT_NAME</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
                <configuration>
                    <debug>true</debug>
                </configuration>
            </plugin>

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <version>3.4.0</version>
            </plugin>

            <!-- Tomcat 10 Plugin -->
            <plugin>
                <groupId>org.codehaus.mojo</groupId>
                <artifactId>tomcat-maven-plugin</artifactId>
                <version>1.1</version>
                <configuration>
                    <path>/app</path>
                    <port>8080</port>
                </configuration>
            </plugin>
        </plugins>

    </build>
</project>
EOF
    sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/pom.xml"
    print_success "Created pom.xml (Jakarta EE template)"
}

create_rest_api_pom() {
    cat > "$PROJECT_DIR/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>PROJECT_NAME</artifactId>
    <version>1.0.0</version>
    <packaging>war</packaging>

    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <jakarta-ee.version>10.0.0</jakarta-ee.version>
        <jackson.version>2.16.0</jackson.version>
    </properties>

    <dependencies>
        <!-- Jakarta EE -->
        <dependency>
            <groupId>jakarta.platform</groupId>
            <artifactId>jakarta.jakartaee-api</artifactId>
            <version>${jakarta-ee.version}</version>
            <scope>provided</scope>
        </dependency>

        <!-- Jakarta REST (JAX-RS) -->
        <dependency>
            <groupId>jakarta.ws.rs</groupId>
            <artifactId>jakarta.ws.rs-api</artifactId>
            <version>3.1.0</version>
            <scope>provided</scope>
        </dependency>

        <!-- Jersey: Jakarta REST Implementation -->
        <dependency>
            <groupId>org.glassfish.jersey.core</groupId>
            <artifactId>jersey-server</artifactId>
            <version>3.1.5</version>
        </dependency>

        <dependency>
            <groupId>org.glassfish.jersey.containers</groupId>
            <artifactId>jersey-container-servlet</artifactId>
            <version>3.1.5</version>
        </dependency>

        <!-- JSON Processing with Jackson -->
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
            <version>${jackson.version}</version>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.10.0</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <finalName>PROJECT_NAME</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
            </plugin>

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <version>3.4.0</version>
            </plugin>

            <!-- Tomcat Plugin -->
            <plugin>
                <groupId>org.codehaus.mojo</groupId>
                <artifactId>tomcat-maven-plugin</artifactId>
                <version>1.1</version>
                <configuration>
                    <path>/api</path>
                    <port>8080</port>
                </configuration>
            </plugin>
        </plugins>

    </build>
</project>
EOF
    sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/pom.xml"
    print_success "Created pom.xml (REST API template)"
}

create_web_xml() {
    mkdir -p "$PROJECT_DIR/src/main/webapp/WEB-INF"
    cat > "$PROJECT_DIR/src/main/webapp/WEB-INF/web.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee
                             https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
         version="6.0">

    <display-name>J2EE Application</display-name>
    <description>Sample J2EE application</description>

    <!-- Default servlet mapping -->
    <servlet>
        <servlet-name>default</servlet-name>
        <servlet-class>org.apache.catalina.servlets.DefaultServlet</servlet-class>
    </servlet>

    <!-- Logging configuration -->
    <context-param>
        <param-name>log-level</param-name>
        <param-value>INFO</param-value>
    </context-param>

    <!-- Session configuration -->
    <session-config>
        <cookie-config>
            <http-only>true</http-only>
            <secure>false</secure>
        </cookie-config>
        <tracking-mode>COOKIE</tracking-mode>
    </session-config>

</web-app>
EOF
    print_success "Created web.xml"
}

create_jdtls_config() {
    cat > "$PROJECT_DIR/.project" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<projectDescription>
    <name>PROJECT_NAME</name>
    <comment></comment>
    <projects>
    </projects>
    <buildSpec>
        <buildCommand>
            <name>org.eclipse.jdt.core.javabuilder</name>
            <arguments>
            </arguments>
        </buildCommand>
        <buildCommand>
            <name>org.eclipse.m2e.core.maven2Builder</name>
            <arguments>
            </arguments>
        </buildCommand>
    </buildSpec>
    <natures>
        <nature>org.eclipse.jdt.core.javanature</nature>
        <nature>org.eclipse.m2e.core.maven2Nature</nature>
    </natures>
    <linkedResources>
    </linkedResources>
    <filteredResources>
    </filteredResources>
</projectDescription>
EOF
    sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/.project"

    cat > "$PROJECT_DIR/.classpath" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<classpath>
    <classpathentry kind="src" path="src/main/java" output="target/classes"/>
    <classpathentry kind="src" path="src/test/java" output="target/test-classes"/>
    <classpathentry kind="src" path="src/main/resources" output="target/classes"/>
    <classpathentry kind="con" path="org.eclipse.jdt.launching.JRE_CONTAINER/org.eclipse.jdt.internal.debug.ui.launcher.StandardVMType/JavaSE-17"/>
    <classpathentry kind="con" path="org.eclipse.m2e.MAVEN2_CLASSPATH_CONTAINER">
        <attributes>
            <attribute name="maven.pomderived" value="true"/>
        </attributes>
    </classpathentry>
    <classpathentry kind="output" path="target/classes"/>
</classpath>
EOF
    print_success "Created JDTLS configuration (.project, .classpath)"
}

create_vscode_settings() {
    cat > "$PROJECT_DIR/.vscode/settings.json" << 'EOF'
{
    "java.home": "${JAVA_HOME}",
    "java.compile.nullAnalysis.mode": "automatic",
    "java.saveActions.organizeImports": true,
    "[java]": {
        "editor.defaultFormatter": "redhat.java",
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
            "source.organizeImports": "explicit"
        }
    }
}
EOF
    print_success "Created VS Code workspace settings"
}

create_sample_servlet() {
    cat > "$PACKAGE_DIR/HelloServlet.java" << 'EOF'
package PACKAGE_NAME;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@jakarta.servlet.annotation.WebServlet("/hello")
public class HelloServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head><title>Hello Servlet</title></head>");
            out.println("<body>");
            out.println("<h1>Hello from Neovim J2EE!</h1>");
            out.println("<p>Timestamp: " + new java.util.Date() + "</p>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
EOF
    sed -i "s/PACKAGE_NAME/$JAVA_PACKAGE/g" "$PACKAGE_DIR/HelloServlet.java"
    print_success "Created sample servlet"
}

create_jsp_page() {
    cat > "$PROJECT_DIR/src/main/webapp/index.jsp" << 'EOF'
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>J2EE JSP App</title>
    <style>
        body { font-family: sans-serif; max-width: 780px; margin: 3rem auto; padding: 0 1rem; }
        .card { border: 1px solid #ddd; border-radius: 10px; padding: 1rem 1.25rem; }
        code { background: #f7f7f7; padding: 0.15rem 0.4rem; border-radius: 6px; }
    </style>
</head>
<body>
    <div class="card">
        <h1>JSP Web App Ready</h1>
        <p>Server time: <%= new java.util.Date() %></p>
        <p>Try servlet endpoint: <a href="hello">/hello</a></p>
    </div>
</body>
</html>
EOF
    print_success "Created JSP page (src/main/webapp/index.jsp)"
}

create_spring_boot_app() {
    cat > "$PACKAGE_DIR/Application.java" << 'EOF'
package PACKAGE_NAME;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @RestController
    public static class HelloController {
        @GetMapping("/hello")
        public String hello() {
            return "Hello from Spring Boot!";
        }
    }
}
EOF
    sed -i "s/PACKAGE_NAME/$JAVA_PACKAGE/g" "$PACKAGE_DIR/Application.java"
    
    cat > "$PROJECT_DIR/src/main/resources/application.properties" << 'EOF'
server.port=8080
server.servlet.context-path=/
spring.application.name=j2ee-app
logging.level.root=INFO
EOF
    
    print_success "Created Spring Boot application"
}

create_jakarta_app() {
    cat > "$PACKAGE_DIR/HelloServlet.java" << 'EOF'
package PACKAGE_NAME;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(urlPatterns = "/hello", description = "Hello Jakarta EE Servlet")
public class HelloServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        response.getWriter().println(
            "<!DOCTYPE html><html><body>" +
            "<h1>Hello Jakarta EE!</h1>" +
            "<p>Running on: " + request.getServerName() + "</p>" +
            "</body></html>"
        );
    }
}
EOF
    sed -i "s/PACKAGE_NAME/$JAVA_PACKAGE/g" "$PACKAGE_DIR/HelloServlet.java"
    print_success "Created Jakarta EE servlet"
}

create_rest_endpoint() {
    mkdir -p "$PACKAGE_DIR/rest"
    cat > "$PACKAGE_DIR/rest/UserResource.java" << 'EOF'
package PACKAGE_NAME.rest;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.util.*;

@Path("/users")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class UserResource {

    private static List<String> users = Arrays.asList("Alice", "Bob", "Charlie");

    @GET
    public Response getAllUsers() {
        return Response.ok(users).build();
    }

    @GET
    @Path("/{id}")
    public Response getUser(@PathParam("id") int id) {
        if (id >= 0 && id < users.size()) {
            return Response.ok(users.get(id)).build();
        }
        return Response.status(Response.Status.NOT_FOUND).build();
    }

    @POST
    public Response createUser(String user) {
        users.add(user);
        return Response.status(Response.Status.CREATED).entity(user).build();
    }

    @DELETE
    @Path("/{id}")
    public Response deleteUser(@PathParam("id") int id) {
        if (id >= 0 && id < users.size()) {
            String removed = users.remove(id);
            return Response.ok(removed).build();
        }
        return Response.status(Response.Status.NOT_FOUND).build();
    }
}
EOF
    sed -i "s/PACKAGE_NAME/$JAVA_PACKAGE/g" "$PACKAGE_DIR/rest/UserResource.java"

    cat > "$PACKAGE_DIR/rest/RestApplication.java" << 'EOF'
package PACKAGE_NAME.rest;

import jakarta.ws.rs.ApplicationPath;
import jakarta.ws.rs.core.Application;

@ApplicationPath("/api")
public class RestApplication extends Application {
}
EOF
    sed -i "s/PACKAGE_NAME/$JAVA_PACKAGE/g" "$PACKAGE_DIR/rest/RestApplication.java"
    
    print_success "Created REST API endpoints"
}

create_test_class() {
    cat > "$PROJECT_DIR/src/test/java/${JAVA_PACKAGE//./\/}/SampleTest.java" << 'EOF'
package PACKAGE_NAME;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class SampleTest {

    @BeforeEach
    public void setUp() {
        // Test setup
    }

    @Test
    public void testExample() {
        assertTrue(true, "This test should pass");
    }

    @Test
    public void testArithmetic() {
        assertEquals(2, 1 + 1, "1 + 1 should equal 2");
    }
}
EOF
    sed -i "s/PACKAGE_NAME/$JAVA_PACKAGE/g" "$PROJECT_DIR/src/test/java/${JAVA_PACKAGE//./\/}/SampleTest.java"
    print_success "Created test class"
}

create_readme() {
    cat > "$PROJECT_DIR/README.md" << 'EOF'
# $PROJECT_NAME

J2EE/Servlet Application using Maven and Tomcat

## Build & Run

```bash
# Build
mvn clean compile

# Test
mvn test

# Package
mvn clean package

# Deploy to installed Tomcat 10
~/.config/nvim/java-workspace/tomcat10-setup.sh deploy target/*.war
```

## Debug with Neovim

1. Set breakpoint: `<leader>db`
2. Start debugging: `<leader>dc`
3. Step into: `<leader>di`
4. Continue: `<leader>dc`

## Project Structure

```
.
├── src/
│   ├── main/
│   │   ├── java/      # Java source files
│   │   ├── webapp/    # Web resources (JSP, CSS, JS)
│   │   └── resources/ # Application properties
│   └── test/
│       ├── java/      # Test classes
│       └── resources/ # Test resources
├── target/            # Compiled output
├── pom.xml           # Maven configuration
└── README.md
```

## Technologies

- **Java**: 17 LTS
- **Build Tool**: Maven 3.8+
- **Container**: Apache Tomcat 10
- **Jakarta EE**: 10.0.0 (J2EE replacement)

EOF
    sed -i "s/\$PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/README.md"
    print_success "Created README.md"
}

main "$@"
