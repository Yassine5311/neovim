#!/bin/bash
# J2EE Development Environment Setup
# Configures everything needed for J2EE development with Neovim

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ${NC} $*"; }
print_success() { echo -e "${GREEN}✓${NC} $*"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $*"; }
print_error() { echo -e "${RED}✗${NC} $*"; }

echo "╔═══════════════════════════════════════════╗"
echo "║   J2EE Development Environment Setup      ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

# Check Java installation
print_info "Checking Java installation..."
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n1)
    print_success "Java found: $JAVA_VERSION"
else
    print_error "Java not found. Please install JDK 11+"
    echo "  Ubuntu/Debian: sudo apt install openjdk-21-jdk"
    echo "  macOS: brew install openjdk@21"
    echo "  Fedora: sudo dnf install java-21-openjdk"
    exit 1
fi

# Check Maven installation
print_info "Checking Maven installation..."
if command -v mvn &> /dev/null; then
    MVN_VERSION=$(mvn --version | head -n1)
    print_success "Maven found: $MVN_VERSION"
else
    print_warning "Maven not found. Installing..."
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install maven -y
    elif command -v brew &> /dev/null; then
        brew install maven
    elif command -v dnf &> /dev/null; then
        sudo dnf install maven -y
    else
        print_error "Package manager not found. Install Maven manually"
        exit 1
    fi
    print_success "Maven installed"
fi

# Check Docker (optional)
print_info "Checking Docker installation..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    print_success "Docker found: $DOCKER_VERSION"
else
    print_warning "Docker not found (optional for containerization)"
fi

# Setup JAVA_HOME
print_info "Configuring JAVA_HOME..."
JAVA_BIN=$(which java)
JAVA_PATH=$(dirname $(dirname $(readlink -f $JAVA_BIN)))

if [ -z "$JAVA_HOME" ]; then
    export JAVA_HOME=$JAVA_PATH
    print_success "JAVA_HOME set to: $JAVA_HOME"
    
    # Add to shell profile
    for PROFILE in ~/.bashrc ~/.bash_profile ~/.zshrc; do
        if [ -f "$PROFILE" ]; then
            if ! grep -q "export JAVA_HOME=" "$PROFILE"; then
                echo "" >> "$PROFILE"
                echo "# J2EE Development" >> "$PROFILE"
                echo "export JAVA_HOME=$JAVA_PATH" >> "$PROFILE"
                print_success "Added to $PROFILE"
            fi
        fi
    done
else
    print_success "JAVA_HOME already set: $JAVA_HOME"
fi

# Setup Neovim integration
print_info "Setting up Neovim integration..."

NVIM_CONFIG="$HOME/.config/nvim"
if [ -d "$NVIM_CONFIG" ]; then
    # Copy snippet templates
    if [ -f "snippets/java-j2ee.json" ]; then
        SNIPPET_DIR="$NVIM_CONFIG/snippets"
        mkdir -p "$SNIPPET_DIR"
        cp snippets/java-j2ee.json "$SNIPPET_DIR/"
        print_success "Installed J2EE snippets"
    fi
    
    # Copy debug configuration
    if [ -f "tomcat-debug-config.lua" ]; then
        LUA_DIR="$NVIM_CONFIG/lua/plugins"
        mkdir -p "$LUA_DIR"
        cp tomcat-debug-config.lua "$LUA_DIR/java-debug.lua"
        print_success "Installed Tomcat debug config"
    fi
else
    print_warning "Neovim not configured. Skipping integration."
fi

# Maven cache warmup
print_info "Warming up Maven cache..."
mvn -v > /dev/null 2>&1 && print_success "Maven cache warmed"

# Create local properties file
if [ ! -f "local.properties" ]; then
    cat > local.properties << EOF
# Local Development Properties
java.home=$JAVA_HOME
maven.home=$(dirname $(which mvn))
tomcat.port=8080
debug.port=8000
database.url=jdbc:postgresql://localhost:5432/j2eedb
database.user=j2eeuser
database.password=j2eepass
EOF
    print_success "Created local.properties"
fi

# Setup Maven settings
MAVEN_SETTINGS="$HOME/.m2/settings.xml"
if [ ! -f "$MAVEN_SETTINGS" ]; then
    mkdir -p "$HOME/.m2"
    cat > "$MAVEN_SETTINGS" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<settings>
    <mirrors>
        <mirror>
            <id>aliyun</id>
            <name>Aliyun Maven Mirror</name>
            <url>https://maven.aliyun.com/repository/public</url>
            <mirrorOf>central</mirrorOf>
        </mirror>
    </mirrors>
    <profiles>
        <profile>
            <id>default</id>
            <repositories>
                <repository>
                    <id>central</id>
                    <name>Maven Central</name>
                    <url>https://repo.maven.apache.org/maven2</url>
                    <layout>default</layout>
                </repository>
                <repository>
                    <id>apache-snapshots</id>
                    <name>Apache Snapshots</name>
                    <url>https://repository.apache.org/content/repositories/snapshots</url>
                    <layout>default</layout>
                </repository>
            </repositories>
        </profile>
    </profiles>
    <activeProfiles>
        <activeProfile>default</activeProfile>
    </activeProfiles>
</settings>
EOF
    print_success "Created Maven settings"
fi

# Final status
echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║         Setup Complete! ✅                ║"
echo "╚═══════════════════════════════════════════╝"
echo ""
echo "📋 Environment Summary:"
echo "  Java: $(java -version 2>&1 | head -n1)"
echo "  Maven: $(mvn --version | grep -i version | head -n1)"
echo "  JAVA_HOME: $JAVA_HOME"
echo "  Neovim Config: $NVIM_CONFIG"
echo ""
echo "🚀 Quick Start:"
echo "  1. Create project: ./scaffold-project.sh myapp rest-api"
echo "  2. Enter project: cd myapp"
echo "  3. Build: mvn clean compile"
echo "  4. Run: mvn tomcat7:run"
echo ""
echo "🐛 Debugging in Neovim:"
echo "  :set breakpoint     <leader>db"
echo "  :start debug        <leader>dc"
echo "  :step into          <leader>di"
echo "  :continue           <leader>dc"
echo ""
echo "📚 Documentation:"
echo "  cat README.md          # Setup guide"
echo "  cat JAVA_SETUP.md      # Java development guide"
echo "  make help              # Makefile targets"
echo ""
print_success "Environment ready for J2EE development!"
