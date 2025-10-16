# === backup_garuda_sway.sh ===

#!/bin/bash

# === Settings ===
BACKUP_DIR="$HOME/garuda-sway-backup"
GIT_REPO_URL="git@github.com:eddygarcas/garuda_sway_duarkov.git"
DOTFILES=(.bashrc .zshrc .bash_profile .profile .bash_aliases .xprofile .pam_environment)
CONFIG_DIRS=(sway swayidle waybar nvim wofi foot mako rofi alacritty hyprland gtk-3.0 gtk-4.0 mimeapps.list starship.toml zoxide)
LOCAL_BIN="$HOME/.local/bin"

# === Prepare backup directory ===
rm -rf "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR/config"
mkdir -p "$BACKUP_DIR/dotfiles"
mkdir -p "$BACKUP_DIR/local_bin"
mkdir -p "$BACKUP_DIR/scripts"
mkdir -p "$BACKUP_DIR/autostart"
mkdir -p "$BACKUP_DIR/ssh_gpg"

# === Backup package lists ===
pacman -Qqen >"$BACKUP_DIR/pkglist.txt"
pacman -Qqem >"$BACKUP_DIR/aurlist.txt"

# === Backup config directories ===
for dir in "${CONFIG_DIRS[@]}"; do
  [ -e "$HOME/.config/$dir" ] && cp -r "$HOME/.config/$dir" "$BACKUP_DIR/config/"
done

# === Backup dotfiles ===
for file in "${DOTFILES[@]}"; do
  [ -f "$HOME/$file" ] && cp "$HOME/$file" "$BACKUP_DIR/dotfiles/"
done

# === Backup local scripts ===
if [ -d "$LOCAL_BIN" ]; then
  cp -r "$LOCAL_BIN"/* "$BACKUP_DIR/local_bin/"
fi

# === Backup autostart ===
[ -d "$HOME/.config/autostart" ] && cp -r "$HOME/.config/autostart/"* "$BACKUP_DIR/autostart/"

# === Backup user services ===
systemctl --user list-unit-files --state=enabled >"$BACKUP_DIR/systemd_user_services.txt"

# === Backup crontab ===
crontab -l >"$BACKUP_DIR/crontab.txt" 2>/dev/null

# === Backup SSH and GPG (optional, encrypt separately if needed) ===
#cp -r ~/.ssh "$BACKUP_DIR/ssh_gpg/" 2>/dev/null
#cp -r ~/.gnupg "$BACKUP_DIR/ssh_gpg/" 2>/dev/null

# === Backup Flatpak list ===
flatpak list --app --columns=application >"$BACKUP_DIR/flatpak-list.txt" 2>/dev/null

# === Backup wallpapers, fonts, themes, icons ===
cp -r "$HOME/.fonts" "$BACKUP_DIR/" 2>/dev/null
cp -r "$HOME/.themes" "$BACKUP_DIR/" 2>/dev/null
cp -r "$HOME/.icons" "$BACKUP_DIR/" 2>/dev/null
cp -r "$HOME/Pictures/wallpapers" "$BACKUP_DIR/" 2>/dev/null

# === Copy restore script and self ===
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
cp "$SCRIPT_DIR/garuda_sway_duarkov.sh" "$BACKUP_DIR/scripts/"
cp "$SCRIPT_DIR/restore_garuda_sway_duarkov.sh" "$BACKUP_DIR/scripts/"

# === Git push ===
cd "$BACKUP_DIR"
git init
git config user.name "Eduard Garcia"
git config user.email "edugarcas@gmail.com"
git remote add origin "$GIT_REPO_URL"
git checkout -b main
git add .
git commit -m "Garuda Sway full backup - $(date '+%Y-%m-%d %H:%M:%S')"
git push -f origin main

echo "✅ Full backup pushed to $GIT_REPO_URL"
