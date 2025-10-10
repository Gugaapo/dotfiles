#!/bin/bash
set -e

# ------------------------------
# CONFIGURATION
# ------------------------------
DOTFILES_DIR="$HOME/.dotfiles"
OSH_THEME="binaryanomaly"
ALACRITTY_CONFIG="$DOTFILES_DIR/.config/alacritty/alacritty.toml"
WOFI_THEME_DIR="$HOME/.config/wofi"
WOFI_THEME_FILE="$WOFI_THEME_DIR/theme.rasi"

# ------------------------------
# INSTALL DEPENDENCIES
# ------------------------------
echo "Installing dependencies..."
sudo apt update
sudo apt install -y git curl wget build-essential cmake pkg-config \
    libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev \
    python3 python3-pip alacritty wofi

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

# ------------------------------
# SET UP WOFi THEME
# ------------------------------
echo "Setting up Wofi theme..."
mkdir -p "$WOFI_THEME_DIR"

cat <<'EOF' > "$WOFI_THEME_FILE"
window {
    margin: 0px;
    border: 1px solid #88c0d0;
    background-color: #2e3440;
}

#input {
    margin: 5px;
    border: none;
    color: #d8dee9;
    background-color: #3b4252;
}

#inner-box {
    margin: 5px;
    border: none;
    background-color: #2e3440;
}

#outer-box {
    margin: 5px;
    border: none;
    background-color: #2e3440;
}

#scroll {
    margin: 0px;
    border: none;
}

#text {
    margin: 5px;
    border: none;
    color: #d8dee9;
}

#entry:selected {
    background-color: #3b4252;
}
EOF

# ------------------------------
# CONFIGURE WOFi SHORTCUT (Alt+Space)
# ------------------------------
if [[ "$XDG_CURRENT_DESKTOP" == *KDE* ]]; then
    echo "Configuring Alt+Space to launch Wofi on KDE..."
    kwriteconfig5 --file kglobalshortcutsrc \
        --group "KWin" \
        --key "Activate Application Launcher Widget" "Alt+Space,,wofi -show drun -theme $WOFI_THEME_FILE"
    qdbus org.kde.KWin /KWin reconfigure
elif [[ "$XDG_CURRENT_DESKTOP" == *GNOME* ]]; then
    echo "Configuring Alt+Space to launch Wofi on GNOME..."
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/wofi/']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/wofi/ name 'Wofi'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/wofi/ command "wofi -show drun -theme $WOFI_THEME_FILE"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/wofi/ binding '<Alt>space'
fi

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

echo "Setup complete! Your terminal should now be ready with Oh My Bash, Alacritty, and Wofi."
