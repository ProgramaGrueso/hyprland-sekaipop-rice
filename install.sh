#!/usr/bin/env bash
# Rice Installer: Hyprland + SekaiPop + Kitty + Starship
set -euo pipefail

DIR=$(cd "$(dirname "$0")" && pwd)
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)

echo "=== Instalador de Rice (Hyprland + SekaiPop) ==="

# 1. Instalar dependencias si estamos en Arch/CachyOS
if command -v pacman >/dev/null 2>&1; then
    echo "-> Detectado sistema Arch/CachyOS. ¿Deseas instalar dependencias base? (s/N)"
    read -r resp || resp="s"
    if [[ "$resp" =~ ^[sSyY]$ ]]; then
        echo "-> Instalando paquetes necesarios con pacman / paru / yay..."
        PKGS="hyprland quickshell kitty starship fastfetch qt6-wayland qt6-svg qt6-shadertools wl-clipboard pipewire wireplumber networkmanager upower ttf-jetbrains-mono-nerd"
        if command -v paru >/dev/null 2>&1; then
            paru -S --needed --noconfirm $PKGS || true
        elif command -v yay >/dev/null 2>&1; then
            yay -S --needed --noconfirm $PKGS || true
        else
            sudo pacman -S --needed --noconfirm $PKGS || true
        fi
    fi
fi

# 2. Respaldar y copiar configuraciones
echo "-> Respaldando configuraciones previas a .bak_${BACKUP_DATE}..."
mkdir -p ~/.config ~/.local/share

for cfg in hypr sekaipop kitty fastfetch; do
    if [ -d "$HOME/.config/$cfg" ]; then
        mv "$HOME/.config/$cfg" "$HOME/.config/${cfg}.bak_${BACKUP_DATE}"
        echo "   Respaldo: ~/.config/${cfg}.bak_${BACKUP_DATE}"
    fi
    cp -r "$DIR/config/$cfg" ~/.config/
done

mkdir -p ~/.config/quickshell
if [ -d "$HOME/.config/quickshell/sekaipop" ]; then
    mv "$HOME/.config/quickshell/sekaipop" "$HOME/.config/quickshell/sekaipop.bak_${BACKUP_DATE}"
fi
cp -r "$DIR/config/quickshell/sekaipop" ~/.config/quickshell/

if [ -f "$HOME/.config/starship.toml" ]; then
    cp "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.bak_${BACKUP_DATE}"
fi
cp "$DIR/config/starship.toml" ~/.config/

mkdir -p ~/.local/share/sekaipop
cp -r "$DIR/local_share/sekaipop/"* ~/.local/share/sekaipop/ 2>/dev/null || true

# Permisos de ejecución a scripts
chmod +x ~/.config/hypr/hyprland/scripts/* 2>/dev/null || true
chmod +x ~/.config/quickshell/sekaipop/scripts/* 2>/dev/null || true

echo ""
echo "¡Instalación completada exitosamente!"
echo "Inicia sesión en Hyprland para disfrutar de tu escritorio."
