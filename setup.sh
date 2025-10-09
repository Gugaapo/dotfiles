#!/bin/bash
set -e

# ------------------------------
# CONFIGURATION
# ------------------------------
DOTFILES_DIR="$HOME/.dotfiles"
OSH_THEME="binaryanomaly"
ALACRITTY_CONFIG="$DOTFILES_DIR/.config/alacritty/alacritty.toml"

# ------------------------------
# INSTALL DEPENDENCIES
# ------------------------------
echo "Installing dependencies..."
sudo apt update
sudo apt install -y git curl wget build-essential cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 python3-pip

# Install Alacritty
if ! command -v alacritty &> /dev/null; then
    echo "Installing Alacritty..."
    sudo apt install -y alacritty
fi

# ------------------------------
# CLONE DOTFILES
# ------------------------------
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning dotfiles..."
    git clone https://github.com/Gugaapo/dotfiles.git "$DOTFILES_DIR"
else
    echo "Dotfiles directory already exists, skipping clone."
fi

# ------------------------------
# INSTALL OH-MY-BASH
# ------------------------------
if [ ! -d "$HOME/.oh-my-bash" ]; then
    echo "Installing Oh My Bash..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
else
    echo "Oh My Bash already installed."
fi

# ------------------------------
# SYMLINK CONFIG FILES
# ------------------------------
echo "Linking dotfiles..."
ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
ln -sf "$DOTFILES_DIR/.dir_history.sh" "$HOME/.dir_history.sh"
mkdir -p "$HOME/.config/alacritty"
ln -sf "$ALACRITTY_CONFIG" "$HOME/.config/alacritty/alacritty.toml"

# ------------------------------------------------------
# update gnome-terminal shortcut for Ctrl+Alt+T
# ------------------------------------------------------
if command -v gsettings &> /dev/null; then
    echo "Updating GNOME shortcut for Ctrl+Alt+T..."
    gsettings set org.gnome.desktop.default-applications.terminal exec 'alacritty'
    gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''
fi

# ------------------------------------------------------
# Set KDE Plasma or Gnome workspace shortcuts (Alt+Shift+1-9)
# -------------------------------------------------------
echo "Configuring workspace shortcuts..."

if [[ "$XDG_CURRENT_DESKTOP" == *KDE* ]]; then
    echo "Detected KDE Plasma..."
    for i in {1..9}; do
        # Set shortcut to switch to desktop i using Alt+Shift+i
        kwriteconfig5 --file kglobalshortcutsrc \
            --group "kwin" \
            --key "Switch to Desktop $i" "Alt+Shift+$i,,$i"
    done

    # Reload KWin to apply the shortcuts
    qdbus org.kde.KWin /KWin reconfigure
    echo "KDE Plasma workspace shortcuts set: Alt+Shift+1-9"

elif [[ "$XDG_CURRENT_DESKTOP" == *GNOME* ]]; then
    echo "Detected GNOME..."
    for i in {1..9}; do
        # Workspace shortcuts: switch to workspace i
        gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i \
            "['<Alt><Shift>$i']"
    done
    echo "GNOME workspace shortcuts set: Alt+Shift+1-9"

else
    echo "Unsupported desktop environment for workspace shortcuts: $XDG_CURRENT_DESKTOP"
fi



# ------------------------------
#SET OH-MY-BASH THEME AND LOAD BASHRC
# ------------------------------
sed -i "s/^OSH_THEME=.*/OSH_THEME=\"$OSH_THEME\"/" "$HOME/.bashrc"

echo "Sourcing .bashrc..."
source "$HOME/.bashrc"

echo "Setup complete! Your terminal should now be ready with Oh My Bash and Alacritty."
