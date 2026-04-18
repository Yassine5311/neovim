#!/usr/bin/env bash

set -e

echo "================================================="
echo "  Setting up ZERO's 2026 Neovim Configuration"
echo "================================================="

NVIM_DIR="$HOME/.config/nvim"
BACKUP_DIR="$HOME/.config/nvim.bak.$(date +%Y%m%d_%H%M%S)"
REPO_URL="https://github.com/Yassine5311/neovim.git"

# 1. Backup existing configuration if it exists and is not this repo
if [ -d "$NVIM_DIR" ]; then
    if [ -d "$NVIM_DIR/.git" ]; then
        REMOTE=$(git -C "$NVIM_DIR" config --get remote.origin.url)
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
        echo "  [WARN] '$cmd' is not installed. Please install it for the setup to work perfectly."
        MISSING_DEPS=$((MISSING_DEPS+1))
    else
        echo "  [OK] $cmd"
    fi
done

if [ $MISSING_DEPS -gt 0 ]; then
    echo "=> Some dependencies are missing. You can install them via your package manager (e.g., apt, dnf, pacman, brew)."
fi

echo ""
echo "=> Bootstrapping lazy.nvim and installing plugins (this may take a moment)..."
# Run nvim headlessly to trigger plugin installs
nvim --headless "+Lazy! sync" +qa

echo ""
echo "================================================="
echo "  Installation Complete!"
echo "  Run 'nvim' to start using your new configuration."
echo "================================================="
