#!/usr/bin/env bash
set -eo pipefail

# ==============================================================================
# Variables
# ==============================================================================
NVIM_DIR="$HOME/.config/nvim"
NVIM_SHARE="$HOME/.local/share/nvim"
NVIM_STATE="$HOME/.local/state/nvim"
NVIM_CACHE="$HOME/.cache/nvim"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d_%H%M%S)"
REPO_URL="https://github.com/Yassine5311/neovim.git"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Feature flags
OPT_JAVA=false
OPT_PYTHON=false
OPT_GO=false
OPT_RUST=false
OPT_CLIPBOARD=false
OPT_LAZYGIT=false

# ==============================================================================
# Helper Functions
# ==============================================================================
msg() { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err() { echo -e "${RED}[ERROR]${NC} $1"; }

trap "echo -e '\n${RED}Installation interrupted by user.${NC} Exiting.'; exit 1" SIGINT

# ==============================================================================
# Core Functions
# ==============================================================================

prompt_options() {
    echo -e "\n================================================="
    echo -e "  ${BLUE}Optional Languages & Features${NC}"
    echo -e "================================================="
    read -r -p "Install Java/J2EE tools (JDK, Maven)? [y/N]: " ans; [[ ${ans,,} == "y" ]] && OPT_JAVA=true || OPT_JAVA=false
    read -r -p "Install Python tools (pip, venv)? [y/N]: " ans; [[ ${ans,,} == "y" ]] && OPT_PYTHON=true || OPT_PYTHON=false
    read -r -p "Install Go tools? [y/N]: " ans; [[ ${ans,,} == "y" ]] && OPT_GO=true || OPT_GO=false
    read -r -p "Install Rust tools (rustup)? [y/N]: " ans; [[ ${ans,,} == "y" ]] && OPT_RUST=true || OPT_RUST=false
    read -r -p "Install System Clipboard (xclip/wl-clipboard)? [y/N]: " ans; [[ ${ans,,} == "y" ]] && OPT_CLIPBOARD=true || OPT_CLIPBOARD=false
    read -r -p "Install Lazygit (Git TUI)? [y/N]: " ans; [[ ${ans,,} == "y" ]] && OPT_LAZYGIT=true || OPT_LAZYGIT=false
    echo ""
}

install_dependencies() {
    prompt_options
    msg "Diagnosing OS and installing dependencies..."
    
    local DEB_PKGS="neovim git nodejs npm ripgrep fd-find build-essential"
    local RPM_PKGS="neovim git nodejs ripgrep fd-find gcc make"
    local ARCH_PKGS="neovim git nodejs npm ripgrep fd gcc make"
    local MAC_PKGS="neovim git node ripgrep fd make gcc"

    # Append optional packages
    if [ "$OPT_JAVA" = true ]; then
        DEB_PKGS+=" default-jdk maven"
        RPM_PKGS+=" java-17-openjdk-devel maven"
        ARCH_PKGS+=" jdk17-openjdk maven"
        MAC_PKGS+=" openjdk maven"
    fi
    if [ "$OPT_PYTHON" = true ]; then
        DEB_PKGS+=" python3-pip python3-venv"
        RPM_PKGS+=" python3-pip"
        ARCH_PKGS+=" python-pip"
        MAC_PKGS+=" python"
    fi
    if [ "$OPT_GO" = true ]; then
        DEB_PKGS+=" golang"
        RPM_PKGS+=" golang"
        ARCH_PKGS+=" go"
        MAC_PKGS+=" go"
    fi
    if [ "$OPT_CLIPBOARD" = true ]; then
        DEB_PKGS+=" xclip wl-clipboard"
        RPM_PKGS+=" xclip wl-clipboard"
        ARCH_PKGS+=" xclip wl-clipboard"
    fi
    
    if command -v apt-get &> /dev/null; then
        msg "Detected Debian/Ubuntu-based system."
        sudo apt-get update
        if [ "$OPT_LAZYGIT" = true ]; then
            LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
            tar xf lazygit.tar.gz lazygit
            sudo install lazygit /usr/local/bin
            rm lazygit.tar.gz lazygit
        fi
        sudo apt-get install -y $DEB_PKGS
        
        if [[ ! -x "$(command -v fd)" ]] && [[ -x "$(command -v fdfind)" ]]; then
            msg "Linking fdfind to fd..."
            sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd || warn "Failed to create fd symlink. You may need to do this manually."
        fi

    elif command -v dnf &> /dev/null; then
        msg "Detected Fedora/RHEL-based system."
        if [ "$OPT_LAZYGIT" = true ]; then
            sudo dnf copr enable -y atim/lazygit
            RPM_PKGS+=" lazygit"
        fi
        sudo dnf install -y $RPM_PKGS

    elif command -v pacman &> /dev/null; then
        msg "Detected Arch-based system."
        if [ "$OPT_LAZYGIT" = true ]; then ARCH_PKGS+=" lazygit"; fi
        sudo pacman -S --needed --noconfirm $ARCH_PKGS

    elif command -v brew &> /dev/null; then
        msg "Detected macOS/Homebrew environment."
        if [ "$OPT_LAZYGIT" = true ]; then MAC_PKGS+=" lazygit"; fi
        brew install $MAC_PKGS

    else
        err "Unsupported package manager."
        return 1
    fi

    if [ "$OPT_RUST" = true ]; then
        if ! command -v rustup &> /dev/null; then
            msg "Installing Rustup..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        else
            success "Rust is already installed."
        fi
    fi
    
    success "Dependencies installed."
}

backup_neovim_data() {
    for dir in "$NVIM_SHARE" "$NVIM_STATE" "$NVIM_CACHE"; do
        if [ -d "$dir" ]; then
            msg "Backing up data directory: $dir"
            mv "$dir" "${dir}${BACKUP_SUFFIX}"
        fi
    done
}

install_config() {
    echo -e "\n================================================="
    echo -e "  Setting up ZERO's Neovim Configuration"
    echo -e "=================================================\n"

    if [ -d "$NVIM_DIR" ]; then
        if [ -d "$NVIM_DIR/.git" ]; then
            REMOTE=$(git -C "$NVIM_DIR" config --get remote.origin.url || echo "")
            if [ "$REMOTE" = "$REPO_URL" ]; then
                msg "Configuration repository already exists. Pulling latest changes..."
                git -C "$NVIM_DIR" pull origin main || warn "Failed to pull latest changes. Branch might not be 'main'."
            else
                msg "Found different Neovim setup. Backing up..."
                mv "$NVIM_DIR" "${NVIM_DIR}${BACKUP_SUFFIX}"
                backup_neovim_data
                msg "Cloning repository..."
                git clone "$REPO_URL" "$NVIM_DIR"
            fi
        else
            msg "Backing up existing non-git Neovim config..."
            mv "$NVIM_DIR" "${NVIM_DIR}${BACKUP_SUFFIX}"
            backup_neovim_data
            msg "Cloning repository..."
            git clone "$REPO_URL" "$NVIM_DIR"
        fi
    else
        backup_neovim_data
        msg "Cloning repository..."
        git clone "$REPO_URL" "$NVIM_DIR"
    fi

    echo ""
    msg "Checking dependencies..."
    local MISSING_DEPS=0
    for cmd in nvim git node rg fd make cc; do
        if ! command -v "$cmd" &> /dev/null; then
            warn "'$cmd' is not installed or not in PATH."
            MISSING_DEPS=$((MISSING_DEPS+1))
        else
            success "$cmd"
        fi
    done

    if [ "$MISSING_DEPS" -gt 0 ]; then
        warn "Some dependencies are missing. Please run option 1 from the menu."
    fi

    echo ""
    msg "Bootstrapping lazy.nvim and installing plugins (this may take a moment)..."
    
    if nvim --headless "+Lazy! sync" +qa; then
        echo -e "\n================================================="
        success "Installation Complete!"
        echo -e "  Run 'nvim' to start using your new configuration."
        echo -e "=================================================\n"
    else
        err "Neovim plugin synchronization failed. Please check your config."
    fi
}

show_menu() {
    echo -e "\n================================================="
    echo -e "  ${BLUE}Neovim Configuration Installer${NC}"
    echo -e "================================================="
    echo "1) Install system dependencies (Debian/Ubuntu, Fedora, Arch, macOS)"
    echo "2) Install/Update Neovim configuration"
    echo "3) Install Both (Dependencies + Config)"
    echo "4) Quit"
    echo -e "================================================="
}

# ==============================================================================
# Main Loop
# ==============================================================================

while true; do
    show_menu
    read -r -p "Select an option [1-4]: " choice
    echo ""
    case "$choice" in
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
            msg "Exiting."
            exit 0
            ;;
        *)
            warn "Invalid option. Please enter a number between 1 and 4."
            ;;
    esac
done
