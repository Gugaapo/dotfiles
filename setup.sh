#!/usr/bin/env bash
# =====================================
#   Gugaapo's Linux Environment Setup
#   Debian 13 (Trixie) - KDE + Wayland
# =====================================

set -e

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"
LOG_FILE="/tmp/dotfiles_setup.log"
INSTALL_REPORT="/tmp/dotfiles_report.txt"

echo "🚀 Starting setup..."
echo "" > "$LOG_FILE"
echo "" > "$INSTALL_REPORT"

# -------------------------------------
# Helper Functions
# -------------------------------------

run_step() {
  local description="$1"
  shift
  echo -e "\n🔧 $description..." | tee -a "$LOG_FILE"
  if "$@" >>"$LOG_FILE" 2>&1; then
    echo "✅ $description completed." | tee -a "$INSTALL_REPORT"
  else
    echo "❌ $description failed. Check $LOG_FILE for details." | tee -a "$INSTALL_REPORT"
    exit 1
  fi
}

log() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

# -------------------------------------
# 1. System Update & Dependencies
# -------------------------------------

run_step "Updating package list" sudo apt update

run_step "Installing dependencies and base packages" sudo apt install -y \
  git curl wget build-essential cmake pkg-config \
  libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev \
  python3 python3-pip alacritty wofi fastfetch bash-completion fonts-noto-color-emoji



# -------------------------------------
# 1.1 Install VS Code
# -------------------------------------
run_step "Installing Visual Studio Code" bash -c "
if ! command -v code >/dev/null 2>&1; then
  # Add Microsoft GPG key
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
  sudo install -o root -g root -m 644 /tmp/microsoft.gpg /usr/share/keyrings/microsoft.gpg

  # Add VS Code repository
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main' | \
      sudo tee /etc/apt/sources.list.d/vscode.list

  # Update package lists and install
  sudo apt update
  sudo apt install -y code
else
  echo '✅  VS Code already installed.' >> $INSTALL_REPORT
fi
"


# -------------------------------------
# 2. Oh My Bash Setup
# -------------------------------------

if [ ! -d "$HOME/.oh-my-bash" ]; then
  run_step "Installing Oh My Bash" \
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
else
  log "✅   Oh My Bash already installed."
fi

# Apply BinaryAnomaly theme
run_step "Applying Oh My Bash theme" bash -c "
mkdir -p \"$HOME/.oh-my-bash/themes/binaryanomaly\" &&
cp -f \"$DOTFILES_DIR/oh-my-bash-custom/themes/binaryanomaly/binaryanomaly.theme.sh\" \
      \"$HOME/.oh-my-bash/themes/binaryanomaly/binaryanomaly.theme.sh\"
"

# Copy aliases
run_step "Copying custom aliases" bash -c "
mkdir -p \"$HOME/.oh-my-bash/custom\" &&
cp -f \"$DOTFILES_DIR/oh-my-bash-custom/aliases/general.aliases.sh\" \"$HOME/.oh-my-bash/custom/my_aliases.aliases.sh\"
"

# Add custom past command for directory history
run_step "Copying dir_history script" bash -c "
mkdir -p \"$HOME/bin\" &&
cp -f \"$DOTFILES_DIR/oh-my-bash-custom/scripts/dir_history.sh\" \"$HOME/bin/past\" &&
chmod +x \"$HOME/bin/past\"
"

# -------------------------------------
# 3. Bash Configuration
# -------------------------------------

run_step "Copying .bashrc" cp -f "$DOTFILES_DIR/bashrc/.bashrc" "$HOME/.bashrc"

# -------------------------------------
# 4. Alacritty Configuration
# -------------------------------------

run_step "Copying Alacritty configuration" bash -c "
mkdir -p \"$CONFIG_DIR/alacritty\" &&
cp -f \"$DOTFILES_DIR/alacritty/alacritty.toml\" \"$CONFIG_DIR/alacritty/alacritty.toml\"
"

# -------------------------------------
# 5. Final Report
# -------------------------------------

log ""
log "✅ Setup complete!"
log "------------------------------------------"
log "📋 Install report:"
cat "$INSTALL_REPORT"
log "------------------------------------------"
log "🪶 You can now restart your terminal or run:"
log "    source ~/.bashrc"
log ""
log "🧩 Alacritty, Wofi, and Oh My Bash have been configured."
log "💾 Logs: $LOG_FILE"
log "------------------------------------------"
