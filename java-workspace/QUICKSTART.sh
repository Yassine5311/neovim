#!/bin/bash
# Quick Start Guide - Copy to your project and run

cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║              J2EE Workspace - Quick Start                      ║
║              Created with Neovim & Modern Java                 ║
╚════════════════════════════════════════════════════════════════╝

📚 WHAT YOU HAVE:

1. 🔧 Project Generator (scaffold-project.sh)
   └─ Create new J2EE projects in seconds
   └─ 4 templates: simple, rest-api, spring-boot, jakarta-ee
   
2. 🚀 Build Tasks (tasks.json)
   └─ Compile, test, package, run with Maven
   └─ Local Tomcat + remote debugging
   └─ Docker build/run commands
   
3. 📝 Code Snippets (snippets/java-j2ee.json)
   └─ Servlet, REST, Filter, Listener templates
   └─ Type prefix + <Tab> to expand
   
4. 🐳 Containerization
   └─ Dockerfile: Production-ready Tomcat image
   └─ docker-compose.yml: Full dev stack
   
5. 🐛 Debug Support (tomcat-debug-config.lua)
   └─ Tomcat attachment debugging
   └─ Maven test debugging
   └─ Enhanced breakpoints
   
6. ⚡ Makefile (Makefile)
   └─ Quick commands: make build, make test, make run
   └─ Docker: make docker-build, make docker-run
   └─ Formatting: make format

════════════════════════════════════════════════════════════════

🚀 GETTING STARTED (5 minutes):

Step 1: Setup Environment
  $ cd ~/.config/nvim/java-workspace
  $ ./setup-env.sh

Step 2: Create Your First Project
  $ ./scaffold-project.sh myapp rest-api
  $ cd myapp

Step 3: Build & Test
  $ mvn clean compile
  $ mvn test

Step 4: Run with Tomcat
  $ mvn tomcat7:run
  $ open http://localhost:8080/app

════════════════════════════════════════════════════════════════

💡 COMMON COMMANDS:

Build & Development:
  mvn clean compile           # Compile
  mvn test                    # Run tests
  mvn clean package           # Build WAR
  mvn tomcat7:run            # Run Tomcat locally
  
Or use Makefile:
  make build                  # Compile
  make test                   # Test
  make dev                    # Build + run
  make format                 # Format code

Debugging (in Neovim):
  <leader>db                  # Set breakpoint
  <leader>dc                  # Start/continue debug
  <leader>di                  # Step into
  <leader>do                  # Step out
  <leader>dO                  # Step over
  <leader>dr                  # REPL

Docker:
  make docker-build           # Build image
  make docker-run            # Run container
  make docker-compose-up     # Full stack (app+DB)

════════════════════════════════════════════════════════════════

🔧 CONFIGURATION:

VS Code/Neovim Tasks:
  → Copy tasks.json to .vscode/
  → Run with Telescope or <F5>

Snippets:
  → Installed to ~/.config/nvim/snippets/
  → Type: servlet<Tab>, rest-resource<Tab>, etc.

Debug Config:
  → Loaded automatically in java.lua
  → Tomcat debug on port 8000
  → Local debug on port 5005

════════════════════════════════════════════════════════════════

📁 PROJECT STRUCTURE:

myapp/
├── src/
│   ├── main/
│   │   ├── java/              # Source code
│   │   ├── webapp/            # Web resources
│   │   │   └── WEB-INF/
│   │   │       └── web.xml
│   │   └── resources/         # Config files
│   └── test/
│       └── java/              # Tests
├── pom.xml                     # Maven config
├── Makefile                    # Commands
└── target/                    # Build output

════════════════════════════════════════════════════════════════

🌐 DEVELOPMENT WORKFLOW:

1. Edit source code in Neovim
2. Format: make format
3. Build: make build
4. Test: make test
5. Debug: Set breakpoint → <leader>db → <leader>dc
6. Deploy: make docker-build && make docker-run

════════════════════════════════════════════════════════════════

🔗 USEFUL RESOURCES:

Java/J2EE:
  - JAVA_SETUP.md              # Full Java guide
  - ENHANCEMENT-CHECKLIST.md   # Feature list
  - java-workspace/README.md   # Detailed docs

Maven:
  - Maven docs: https://maven.apache.org/
  - Guide: mvn help:describe -Dplugin=artifactId

Tomcat:
  - Docs: https://tomcat.apache.org/
  - Default port: 8080
  - Context path: /app

Jakarta EE:
  - Docs: https://jakarta.ee/
  - Replaces old javax.servlet
  - Version: 10.0.0 (modern)

Docker:
  - Compose: docker-compose up -d
  - Logs: docker-compose logs -f
  - Stop: docker-compose down

════════════════════════════════════════════════════════════════

🆘 TROUBLESHOOTING:

Q: Java/Maven not found?
A: Run ./setup-env.sh again and check $JAVA_HOME

Q: Build fails?
A: mvn clean compile -X (verbose)
A: mvn dependency:resolve (check deps)

Q: Tomcat not starting?
A: Port 8080 in use? lsof -i :8080
A: Check logs: tail -f target/tomcat.log

Q: Debug not connecting?
A: Port 8000 free? lsof -i :8000
A: Restart IDE/debug session

Q: Docker build fails?
A: Run mvn clean package first
A: Check Docker daemon: docker ps

════════════════════════════════════════════════════════════════

📝 QUICK TIPS:

✓ Use make help to see all Makefile commands
✓ Snippets save time - learn the prefixes!
✓ Breakpoints: toggle with <leader>db
✓ Tomcat logs: mvn tomcat7:run shows output
✓ Skip tests for faster builds: -DskipTests
✓ Docker: Always start with make docker-build
✓ psql for DB: psql -h localhost -U j2eeuser -d j2eedb

════════════════════════════════════════════════════════════════

🎉 YOU'RE READY!

Next steps:
  1. cd ~/.config/nvim/java-workspace
  2. ./scaffold-project.sh myapi rest-api
  3. cd myapi && make dev
  4. Open http://localhost:8080/app

Questions? Check the README files in java-workspace/

Happy coding! 🚀 ✨

EOF

# Show directory structure
echo ""
echo "📁 Java Workspace Files:"
echo "========================"
ls -lah ~/.config/nvim/java-workspace/ | grep -E "^-|^d" | awk '{print $9, "(" $5 ")"}'
