#!/bin/bash
# Tomcat 10 Setup and Configuration Helper
# Sets up debugging, environment variables, and quick-start commands

CATALINA_HOME="/usr/share/tomcat10"
TOMCAT_USER="tomcat"
TOMCAT_GROUP="tomcat"

# Resolve a usable CATALINA_BASE automatically when not provided.
resolve_catalina_base() {
    if [ -n "$CATALINA_BASE" ]; then
        echo "$CATALINA_BASE"
        return
    fi

    if [ -d "/var/lib/tomcat10" ] && [ -w "/var/lib/tomcat10" ]; then
        echo "/var/lib/tomcat10"
    else
        echo "$HOME/.local/share/tomcat10-base"
    fi
}

CATALINA_BASE="$(resolve_catalina_base)"

write_minimal_conf() {
    mkdir -p "$CATALINA_BASE/conf"

    cat > "$CATALINA_BASE/conf/server.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Server port="8005" shutdown="SHUTDOWN">
  <Service name="Catalina">
    <Connector port="8080" protocol="HTTP/1.1" connectionTimeout="20000" redirectPort="8443" />
    <Engine name="Catalina" defaultHost="localhost">
      <Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true" />
    </Engine>
  </Service>
</Server>
EOF

    cat > "$CATALINA_BASE/conf/web.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
         version="6.0">
</web-app>
EOF

    cat > "$CATALINA_BASE/conf/context.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Context>
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
</Context>
EOF

    cat > "$CATALINA_BASE/conf/tomcat-users.xml" << 'EOF'
<?xml version='1.0' encoding='utf-8'?>
<tomcat-users>
</tomcat-users>
EOF

    cat > "$CATALINA_BASE/conf/catalina.properties" << 'EOF'
common.loader="${catalina.base}/lib","${catalina.base}/lib/*.jar","${catalina.home}/lib","${catalina.home}/lib/*.jar"
server.loader=
shared.loader=

package.access=sun.,org.apache.catalina.,org.apache.coyote.,org.apache.jasper.,org.apache.juli.,org.apache.naming.,org.apache.tomcat.
package.definition=sun.,java.,org.apache.catalina.,org.apache.coyote.,org.apache.jasper.,org.apache.juli.,org.apache.naming.,org.apache.tomcat.
EOF

    cat > "$CATALINA_BASE/conf/logging.properties" << 'EOF'
handlers = java.util.logging.ConsoleHandler
.handlers = java.util.logging.ConsoleHandler
java.util.logging.ConsoleHandler.level = INFO
java.util.logging.ConsoleHandler.formatter = java.util.logging.SimpleFormatter
EOF
}

ensure_catalina_base() {
    mkdir -p "$CATALINA_BASE"/logs "$CATALINA_BASE"/temp "$CATALINA_BASE"/work "$CATALINA_BASE"/webapps

    if [ ! -d "$CATALINA_BASE/conf" ]; then
        if [ -r "/etc/tomcat10/server.xml" ]; then
            ln -s /etc/tomcat10 "$CATALINA_BASE/conf" 2>/dev/null || cp -r /etc/tomcat10 "$CATALINA_BASE/conf"
        elif [ -r "$CATALINA_HOME/conf/server.xml" ]; then
            cp -r "$CATALINA_HOME/conf" "$CATALINA_BASE/conf"
        else
            print_warning "System Tomcat conf is not readable; creating local conf in $CATALINA_BASE/conf"
            write_minimal_conf
        fi
    elif [ ! -r "$CATALINA_BASE/conf/server.xml" ]; then
        print_warning "CATALINA_BASE/conf/server.xml is not readable; recreating local conf"
        rm -rf "$CATALINA_BASE/conf"
        write_minimal_conf
    fi
}

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ${NC} $*"; }
print_success() { echo -e "${GREEN}✓${NC} $*"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $*"; }

# 1. Verify Tomcat 10 installation
verify_tomcat() {
    print_info "Checking Tomcat 10 installation..."
    
    if [ ! -d "$CATALINA_HOME" ]; then
        echo "✗ CATALINA_HOME not found at $CATALINA_HOME"
        return 1
    fi
    
    if [ ! -f "$CATALINA_HOME/bin/catalina.sh" ]; then
        echo "✗ catalina.sh not found at $CATALINA_HOME/bin/catalina.sh"
        return 1
    fi
    
    print_success "Tomcat 10 found at $CATALINA_HOME"
    print_info "Tomcat version: $(grep "CATALINA_VERSION" $CATALINA_HOME/bin/catalina.sh 2>/dev/null | head -1)"
}

# 2. Configure environment variables
setup_environment() {
    print_info "Setting up environment variables..."
    
    # Export if not already set
    export CATALINA_HOME="/usr/share/tomcat10"
    export CATALINA_BASE="$(resolve_catalina_base)"
    export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk}"
    ensure_catalina_base
    
    # Debug options for remote debugging on port 8000
    export CATALINA_OPTS="-Xmx2g \
        -Xms1g \
        -Dcom.sun.jndi.ldap.connect.pool=false \
        -XX:+UseG1GC \
        -XX:MaxGCPauseMillis=200"
    
    print_success "Environment configured:"
    echo "    CATALINA_HOME=$CATALINA_HOME"
    echo "    CATALINA_BASE=$CATALINA_BASE"
    echo "    JAVA_HOME=$JAVA_HOME"
    echo "    Debug port: 8000"
}

# 3. Test Tomcat configuration
test_config() {
    print_info "Testing Tomcat configuration..."
    "$CATALINA_HOME/bin/configtest.sh" && print_success "Configuration OK" || print_warning "Configuration has issues"
}

# 4. Start Tomcat with debugging
start_tomcat_debug() {
    print_info "Starting Tomcat 10 with debugging enabled..."
    print_info "Remote debugging available at: localhost:8000"
    setup_environment
    export JPDA_ADDRESS="8000"
    export JPDA_TRANSPORT="dt_socket"
    "$CATALINA_HOME/bin/catalina.sh" jpda start
    sleep 2
    if pgrep -f "org.apache.catalina.startup.Bootstrap" >/dev/null; then
        print_success "Tomcat started"
    else
        print_warning "Tomcat did not start correctly. Check logs in $CATALINA_BASE/logs"
        return 1
    fi
}

# 5. Start Tomcat normally
start_tomcat() {
    print_info "Starting Tomcat 10..."
    setup_environment
    "$CATALINA_HOME/bin/catalina.sh" start
    sleep 2
    if pgrep -f "org.apache.catalina.startup.Bootstrap" >/dev/null; then
        print_success "Tomcat started"
    else
        print_warning "Tomcat did not start correctly. Check logs in $CATALINA_BASE/logs"
        return 1
    fi
}

# 6. Stop Tomcat
stop_tomcat() {
    print_info "Stopping Tomcat 10..."
    setup_environment
    "$CATALINA_HOME/bin/catalina.sh" stop
    sleep 3
    if pgrep -f "org.apache.catalina.startup.Bootstrap" >/dev/null; then
        print_warning "Tomcat still running"
    else
        print_success "Tomcat stopped"
    fi
}

# 7. Show logs
show_logs() {
    print_info "Tomcat logs:"
    tail -f "$CATALINA_BASE/logs/catalina.out"
}

# 8. Deploy WAR file
deploy_war() {
    if [ -z "$1" ]; then
        echo "Usage: $0 deploy <path-to-war-file>"
        return 1
    fi
    
    WAR_FILE="$1"
    BASENAME=$(basename "$WAR_FILE" .war)
    ensure_catalina_base
    
    print_info "Deploying $BASENAME..."
    cp "$WAR_FILE" "$CATALINA_BASE/webapps/$BASENAME.war"
    print_success "Deployed to $CATALINA_BASE/webapps/$BASENAME.war"
    echo "Access at: http://localhost:8080/$BASENAME"
}

# Main
main() {
    case "${1:-help}" in
        verify)
            verify_tomcat
            ;;
        setup)
            setup_environment
            verify_tomcat
            test_config
            ;;
        start)
            start_tomcat
            ;;
        start-debug)
            start_tomcat_debug
            ;;
        stop)
            stop_tomcat
            ;;
        logs)
            show_logs
            ;;
        deploy)
            shift
            deploy_war "$@"
            ;;
        *)
            echo "Tomcat 10 Helper Script"
            echo ""
            echo "Usage: $0 <command>"
            echo ""
            echo "Commands:"
            echo "  verify       - Check Tomcat 10 installation"
            echo "  setup        - Configure environment and test"
            echo "  start        - Start Tomcat normally"
            echo "  start-debug  - Start Tomcat with remote debugging (port 8000)"
            echo "  stop         - Stop Tomcat"
            echo "  logs         - Follow Tomcat logs"
            echo "  deploy <war> - Deploy WAR file"
            echo ""
            echo "Environment:"
            echo "  CATALINA_HOME:  $CATALINA_HOME"
            echo "  CATALINA_BASE:  $CATALINA_BASE"
            echo "  JAVA_HOME:      ${JAVA_HOME:-not set}"
            ;;
    esac
}

main "$@"
