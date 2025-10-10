# Dotfiles

Personal configuration files for Linux environments, including Alacritty, Oh My Bash, aliases, and custom scripts.

## Features

- **Alacritty Terminal**: Preconfigured with your preferred theme.
- **Oh My Bash**: Includes your selected theme, plugins, aliases, and completions.
- **Directory History Tracking**: Track and quickly navigate previously visited directories using the `past` command.
- **Favorites Directories**: Add frequently used directories to favorites and access them with `past fav <number>`.
- **Workspace Shortcuts**: Switch between desktops/workspaces using `Alt+Shift+1-9` (supports both KDE Plasma and GNOME).
- **Wofi Application Launcher**: Fast application launching with a custom theme, bound to `Alt+Space`.
- **Environment Shortcuts**: Sets Alacritty as the default terminal (Ctrl+Alt+T) in GNOME.
- **Cross-Desktop Support**: Detects KDE Plasma or GNOME and applies relevant configurations automatically.

## Installation on a New Machine

This repository contains a setup script that automatically installs required dependencies and configures your environment. To get started:

1. **Clone the repository**:

```bash
git clone https://github.com/Gugaapo/dotfiles.git
cd dotfiles
```
2. Make the setup script executable:
```bash
chmod +x setup.sh
```
3. Run the setup script:
```bash
./setup.sh
```

The script will:

- Install Alacritty terminal
- Install Oh My Bash
- Configure Alacritty with your preferred theme
- Apply Oh My Bash with your selected theme, plugins, aliases, and completions
- Set up custom scripts, including directory history tracking
- Configure your environment to use Alacritty as the default terminal

After running the script, open a new terminal session. Your environment should be fully configured and ready to use.

---
# Updating Configurations

To update your environment after making changes to the dotfiles:
```bash
cd ~/dotfiles
git pull origin main
./setup_dotfiles.sh
```
---
# Notes

The setup script assumes a Debian-based system.
For other distributions, you may need to adjust the package installation commands in setup.sh.
