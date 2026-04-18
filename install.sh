#!/usr/bin/env bash
set -e

NVIM_DIR="$HOME/.config/nvim"
BACKUP_DIR="$HOME/.config/nvim.bak.$(date +%Y%m%d_%H%M%S)"
REPO_URL="https://github.com/Yassine5311/neovim.git"

install_dependencies() {
    echo "=> Diagnosing OS and installing dependencies..."
    if command -v apt-get &> /dev/null; then
        echo "Detected Debian/Ubuntu-based system."
        sudo apt-get update
        sudo apt-get install -y neovim git nodejs npm ripgrep fd-find build-essential
        [[ ! -f /usr/local/bin/fd ]] && sudo ln -sf $(which fdfind) /usr/local/bin/fd || true
    elif command -v dnf &> /dev/null; then
        echo "Detected Fedora/RHEL-based system."
        sudo dnf install -y neovim git nodejs ripgrep fd-find gcc make
    elif command -v pacman &> /dev/null; then
        echo "Detected Arch-based system."
        sudo pacman -Syu --noconfirm neovim git nodejs npm ripgrep fd gcc make
    elif command -v brew &> /dev/null; then
        echo "Detected macOS/Homebrew environment."
        brew install neovim git node ripgrep fd make gcc
    else
        echo "[ERROR] Unsupported package manager. Please install neovim, git, nodejs, ripgrep, fd, and build tools manually."
    fi
}

install_config() {
    echo "================================================="
    echo "  Setting up ZERO's 2026 Neovim Configuration"
    echo "================================================="

    if [ -d "$NVIM_DIR" ]; then
        if [ -d "$NVIM_DIR/.git" ]; then
            REMOTE=$(git -C "$NVIM_DIR" config --get remote.origin.url || echo "")
            if [ "$REMOTE" = "$REPO_URL" ]; then
                echo "=> Configuration repository already exists. Pulling latest changes..."
                git -C "$NVIM_DIR" pull origin main
            else
                echo "=> Found different Neovim setup. Backing up to $BACKUP_DIR"
                mv "$NVIM_DIR" "$BACKUP_DIR"
                git clone "$REPO_URL" "$NVIM_DIR"
            fi
        else
            echo "=> Backing up existing Neovim config to $BACKUP_DIR"
            mv "$NVIM_DIR" "$BACKUP_DIR"
            git clone "$REPO_URL" "$NVIM_DIR"
        fi
    else
        echo "=> Cloning repository..."
        git clone "$REPO_URL" "$NVIM_DIR"
    fi

    echo ""
    echo "=> Checking dependencies..."
    MISSING_DEPS=0
    for cmd in nvim git node rg fd make cc; do
        if ! command -v $cmd &> /dev/null; then
            echo "  [WARN] '$cmd' is not installed."
            MISSING_DEPS=$((MISSING_DEPS+1))
        else
            echo "  [OK] $cmd"
        fi
    done

    if [ $MISSING_DEPS -gt 0 ]; then
        echo "=> [WARN] Some dependencies are missing. Run option 1 from the menu next time."
    fi

    echo ""
    echo "=> Bootstrapping lazy.nvim and installing plugins (this may take a moment)..."
    nvim --headless "+Lazy! sync" +qa

    echo ""
    echo "================================================="
    echo "  Installation Complete!"
    echo "  Run 'nvim' to start using your new configuration."
    echo "================================================="
}

show_menu() {
    echo "================================================="
    echo "  Neovim 2026 Configuration Installer"
    echo "================================================="
    echo "1) Install system dependencies (Debian/Ubuntu, Fedora, Arch, macOS)"
    echo "2) Install/Update Neovim configuration"
    echo "3) Install Both (Dependencies + Config)"
    echo "4) Quit"
    echo "================================================="
}

while true; do
    show_menu
    read -p "Select an option [1-4]: " choice
    case $choice in
        1)
            install_dependencies
            ;;
        2)
            install_config
            ;;
        3)
            install_dependencies
            install_config
            ;;
        4)
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid option. Please enter a number between 1 and 4."
            ;;
    esac
    echo ""
done
