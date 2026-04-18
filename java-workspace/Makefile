# J2EE Project Makefile
# Common development commands

.PHONY: help build test run debug clean docker-build docker-run docker-stop

# Variables
JAVA_HOME ?= $(shell dirname $(dirname $(readlink -f $(which java))))
MAVEN := mvn
DOCKER_IMAGE := my-j2ee-app:latest
DOCKER_CONTAINER := j2ee-app
APP_PORT := 8080
DEBUG_PORT := 8000

help: ## Show this help message
	@echo "J2EE Project - Available Commands"
	@echo "================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Build targets
build: ## Build project (Maven compile)
	@echo "🔨 Building project..."
	@$(MAVEN) clean compile

build-quick: ## Quick build without cleaning
	@$(MAVEN) compile

build-war: ## Package as WAR for Tomcat
	@echo "📦 Packaging WAR..."
	@$(MAVEN) clean package -DskipTests
	@echo "✅ WAR ready: target/*.war"

# Test targets
test: ## Run all unit tests
	@echo "🧪 Running tests..."
	@$(MAVEN) test

test-single: ## Run single test (TEST=ClassName)
	@$(MAVEN) test -Dtest=$(TEST)

test-skip: ## Build and package, skip tests
	@$(MAVEN) clean package -DskipTests

# Run targets
run: ## Start Tomcat with application
	@echo "🚀 Starting Tomcat on port $(APP_PORT)..."
	@echo "   Access: http://localhost:$(APP_PORT)/app"
	@echo "   Stop: Ctrl+C"
	@$(MAVEN) tomcat7:run

run-debug: ## Start Tomcat with debugging enabled (port 8000)
	@echo "🐛 Starting Tomcat with debugging..."
	@echo "   App: http://localhost:$(APP_PORT)/app"
	@echo "   Debug port: $(DEBUG_PORT)"
	@CATALINA_OPTS='-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=$(DEBUG_PORT)' \
	$(MAVEN) tomcat7:run

# Development targets
dev: build run ## Build and run (development workflow)

dev-debug: build run-debug ## Build and run with debugging

format: ## Format Java code with google-java-format
	@echo "🎨 Formatting code..."
	@find src/main/java -name "*.java" -exec google-java-format -i {} +
	@echo "✅ Code formatted"

lint: ## Run static analysis
	@echo "🔍 Running static analysis..."
	@$(MAVEN) checkstyle:check
	@echo "✅ No style issues found"

format-lint: format lint ## Format code and run linter

# Dependency management
deps: ## Install/resolve dependencies
	@echo "📚 Resolving dependencies..."
	@$(MAVEN) dependency:resolve
	@echo "✅ Dependencies resolved"

deps-tree: ## Display dependency tree
	@$(MAVEN) dependency:tree

deps-update: ## Update dependencies
	@$(MAVEN) dependency:update-snapshots

# Clean targets
clean: ## Clean build artifacts
	@echo "🧹 Cleaning..."
	@$(MAVEN) clean
	@rm -rf target/
	@echo "✅ Cleaned"

clean-cache: ## Clean Maven cache
	@echo "🗑️  Clearing Maven cache..."
	@rm -rf ~/.m2/repository
	@echo "⚠️  This will redownload all dependencies"

clean-all: clean clean-cache ## Full clean (artifacts + cache)

# Docker targets
docker-build: build-war ## Build Docker image
	@echo "🐳 Building Docker image: $(DOCKER_IMAGE)"
	@docker build -t $(DOCKER_IMAGE) -f Dockerfile .
	@echo "✅ Image built: docker run -p $(APP_PORT):$(APP_PORT) $(DOCKER_IMAGE)"

docker-run: ## Run Docker container
	@echo "🐳 Starting container..."
	@docker run -p $(APP_PORT):$(APP_PORT) -p $(DEBUG_PORT):$(DEBUG_PORT) \
		--name $(DOCKER_CONTAINER) -d $(DOCKER_IMAGE)
	@echo "✅ Container running"
	@echo "   App: http://localhost:$(APP_PORT)/app"
	@echo "   Debug: localhost:$(DEBUG_PORT)"

docker-stop: ## Stop Docker container
	@echo "🛑 Stopping container..."
	@docker stop $(DOCKER_CONTAINER)
	@docker rm $(DOCKER_CONTAINER)
	@echo "✅ Container stopped"

docker-logs: ## View Docker logs
	@docker logs -f $(DOCKER_CONTAINER)

docker-compose-up: ## Start full stack (Tomcat + DB)
	@echo "🐳 Starting docker-compose stack..."
	@docker-compose up -d
	@echo "✅ Stack started"
	@echo "   App: http://localhost:8080/app"
	@echo "   DB: localhost:5432"
	@echo "   pgAdmin: http://localhost:5050"

docker-compose-down: ## Stop docker-compose stack
	@echo "🛑 Stopping docker-compose stack..."
	@docker-compose down
	@echo "✅ Stack stopped"

# IDE/Editor targets
ide-vscode: ## Setup VS Code workspace
	@mkdir -p .vscode
	@cp tasks.json .vscode/
	@echo "✅ VS Code workspace configured"

ide-eclipse: ## Generate Eclipse project files
	@echo "🔧 Generating Eclipse files..."
	@$(MAVEN) eclipse:eclipse
	@echo "✅ Ready to import in Eclipse: File > Import > Existing Projects"

# Documentation targets
docs: ## Generate JavaDoc
	@echo "📚 Generating JavaDoc..."
	@$(MAVEN) javadoc:javadoc
	@echo "✅ JavaDoc generated: target/site/apidocs/index.html"

status: ## Show project status
	@echo "📊 Project Status"
	@echo "================"
	@echo "Java version: $$(java -version 2>&1 | head -n1)"
	@echo "Maven version: $$(mvn --version | head -n1)"
	@echo "Tomcat app port: $(APP_PORT)"
	@echo "Debug port: $(DEBUG_PORT)"
	@echo "Build status: $$(test -d target && echo '✅ Built' || echo '⚠️  Not built')"

# Quick reference
info: ## Show quick reference
	@echo "📋 Quick Reference"
	@echo "=================="
	@echo "Build & Run:"
	@echo "  make dev              Build and run Tomcat"
	@echo "  make dev-debug        Build and run with debugging"
	@echo ""
	@echo "Testing:"
	@echo "  make test             Run all tests"
	@echo "  make test-single TEST=HelloTest"
	@echo ""
	@echo "Code Quality:"
	@echo "  make format           Format Java code"
	@echo "  make lint             Run style checker"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-build     Build Docker image"
	@echo "  make docker-run       Start Docker container"
	@echo "  make docker-compose-up   Start full stack"
	@echo ""
	@echo "Details: make help"

.DEFAULT_GOAL := help
