# testapp

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

