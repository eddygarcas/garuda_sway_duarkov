# === restore_garuda_sway.sh ===

#!/bin/bash

BACKUP_DIR="$HOME/garuda-sway-backup"
GIT_REPO_URL="git@github.com:eddygarcas/garuda_sway_duarkov.git"
AUR_HELPER="yay"

# === Clone repo ===
git clone "$GIT_REPO_URL" "$BACKUP_DIR" || {
  echo "❌ Git clone failed"
  exit 1
}

# === Install packages ===
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm - <"$BACKUP_DIR/pkglist.txt"

if command -v $AUR_HELPER >/dev/null 2>&1; then
  $AUR_HELPER -S --needed --noconfirm - <"$BACKUP_DIR/aurlist.txt"
else
  echo "⚠️  AUR helper ($AUR_HELPER) not found."
fi

# === Restore configs, dotfiles, scripts ===
cp -r "$BACKUP_DIR/config/"* "$HOME/.config/"
cp -v "$BACKUP_DIR/dotfiles/"* "$HOME/"
mkdir -p "$HOME/.local/bin" && cp -r "$BACKUP_DIR/local_bin/"* "$HOME/.local/bin/"

# === Autostart ===
mkdir -p "$HOME/.config/autostart"
cp -r "$BACKUP_DIR/autostart/"* "$HOME/.config/autostart/"

# === Fonts, themes, icons, wallpapers ===
cp -r "$BACKUP_DIR/.fonts" "$HOME/" 2>/dev/null
cp -r "$BACKUP_DIR/.themes" "$HOME/" 2>/dev/null
cp -r "$BACKUP_DIR/.icons" "$HOME/" 2>/dev/null
cp -r "$BACKUP_DIR/wallpapers" "$HOME/Pictures/" 2>/dev/null
fc-cache -fv

# === Restore crontab ===
[ -f "$BACKUP_DIR/crontab.txt" ] && crontab "$BACKUP_DIR/crontab.txt"

# === Re-enable user systemd services ===
if [ -f "$BACKUP_DIR/systemd_user_services.txt" ]; then
  grep enabled "$BACKUP_DIR/systemd_user_services.txt" | awk '{print $1}' | while read -r service; do
    systemctl --user enable "$service" 2>/dev/null
  done
fi

# === Restore Flatpaks ===
[ -f "$BACKUP_DIR/flatpak-list.txt" ] && cat "$BACKUP_DIR/flatpak-list.txt" | xargs -n1 flatpak install -y flathub

# === Reload environment ===
source ~/.bashrc 2>/dev/null || source ~/.zshrc 2>/dev/null
systemctl --user daemon-reexec

echo "🎉 Garuda Sway fully restored! Reboot to apply all settings."
