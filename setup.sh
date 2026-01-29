#!/usr/bin/env bash

# ===============================
# Kali Linux Dotfiles Setup
# Author: sweetlord16
# ===============================

set -e

USER_NAME=$(whoami)
BASE_DIR=$(pwd)
CONFIG_DIR="$BASE_DIR/config"

# ---------- Colores ----------
GREEN="\e[1;32m"
RED="\e[1;31m"
BLUE="\e[1;34m"
END="\e[0m"


# --------------------------------------- Banner bien piola --------------------------------------------
function banner(){
	echo -e "\n${turquoiseColour}  _____                   _   _                   _  __    ____ "
	sleep 0.05
	echo -e " /  ___|                 | | | |                 | |/  |  / ___|"
	sleep 0.05
	echo -e " \\ \`--.__      _____  ___| |_| |     ___  _ __ __| |\`| | / /___ "
	sleep 0.05
	echo -e "  \`--. \\ \\ /\\ / / _ \\/ _ \\ __| |    / _ \\| '__/ _\` | | | | ___ \\"
	sleep 0.05
	echo -e " /\\__/ /\\ V  V /  __/  __/ |_| |___| (_) | | | (_| |_| |_| \\_/ |"
	sleep 0.05
	echo -e " \\____/  \\_/\\_/ \\___|\\___|\\__\\_____/\\___/|_|  \\__,_|\\___/\\_____/${endColour}"
}



# ---------- CTRL+C ----------
trap ctrl_c INT
ctrl_c() {
  echo -e "\n${RED}[!] Cancelado por el usuario${END}"
  exit 1
}

# ---------- Root check ----------
if [[ "$USER_NAME" == "root" ]]; then
  banner
  echo -e "${RED}[!] No ejecutes este script como root${END}"
  exit 1
fi

banner
echo -e "${BLUE}[*] Configurando Kali para $USER_NAME${END}"


# ---------- Wallpapers ----------
set_wallpaper() {
    WALLPAPER="$CONFIG_DIR/wallpaper/The\ Oni.jpg"

	if [[ -f "$WALLPAPER" ]]; then
		feh --bg-scale "$WALLPAPER"
		echo -e "${greenColour}[+] Fondo de pantalla aplicado${endColour}"
	else
		echo -e "${redColour}[-] No se encontró el fondo de pantalla${endColour}"
	fi
}

# ===============================
# Paquetes esenciales
# ===============================
echo -e "${BLUE}[*] Instalando paquetes...${END}"

sudo apt update
sudo apt install -y \
  zsh \
  git \
  curl \
  wget \
  kitty \
  fastfetch \
  lolcat \
  feh


echo -e "${GREEN}[+] Paquetes instalados${END}"



set_wallpaper

# ===============================
# ZSH + Oh My Zsh
# ===============================
echo -e "${BLUE}[*] Configurando ZSH...${END}"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

# ===============================
#  Copia de configuraciones
# ===============================
echo -e "${BLUE}[*] Aplicando dotfiles...${END}"

mkdir -p ~/.config

# Kitty
mkdir -p ~/.config/kitty
cp -v "$CONFIG_DIR/kitty/"* ~/.config/kitty/

# Fastfetch
mkdir -p ~/.config/fastfetch/images
cp -v "$CONFIG_DIR/fastfetch/config.jsonc" ~/.config/fastfetch/
cp -v "$CONFIG_DIR/fastfetch/images/"* ~/.config/fastfetch/images/

# ZSH
cp -v "$CONFIG_DIR/zsh/.zshrc" ~/.zshrc
cp -v "$CONFIG_DIR/zsh/.p10k.zsh" ~/.p10k.zsh

echo -e "${GREEN}[+] Dotfiles aplicados${END}"

# ===============================
# Variables de entorno
# ===============================
if ! grep -q "xterm-kitty" ~/.zshrc; then
  echo "export TERM=xterm-kitty" >> ~/.zshrc
fi


# ===============================
# Terminal por defecto (Kitty)
# ===============================
echo -e "${BLUE}[*] Configurando terminal por defecto...${END}"

# Registrar kitty en x-terminal-emulator y seleccionarlo
if command -v kitty &>/dev/null; then
    sudo update-alternatives --install \
      /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 50

    sudo update-alternatives --set x-terminal-emulator /usr/bin/kitty
    echo -e "${GREEN}[+] Kitty registrado como x-terminal-emulator${END}"
else
    echo -e "${RED}[-] Kitty no está instalado, saltando registro en alternatives${END}"
fi

# XFCE: Terminal por defecto
if command -v exo-preferred-applications &>/dev/null; then
    exo-preferred-applications --set TerminalEmulator=kitty
    echo -e "${GREEN}[+] Kitty establecido como terminal por defecto (EXO / XFCE)${END}"
else
    echo -e "${RED}[-] exo-preferred-applications no disponible, omitiendo configuración XFCE${END}"
fi

# Variable de entorno TERMINAL para scripts / WMs
if ! grep -q "export TERMINAL=kitty" ~/.bashrc; then
    echo 'export TERMINAL=kitty' >> ~/.bashrc
    echo -e "${GREEN}[+] Variable de entorno TERMINAL=kitty añadida a ~/.bashrc${END}"
fi
if ! grep -q "export TERMINAL=kitty" ~/.zshrc; then
    echo 'export TERMINAL=kitty' >> ~/.zshrc
    echo -e "${GREEN}[+] Variable de entorno TERMINAL=kitty añadida a ~/.zshrc${END}"
fi



# ===============================
#  Shell por defecto
# ===============================
if [[ "$SHELL" != */zsh ]]; then
  echo -e "${BLUE}[*] Cambiando shell por defecto a ZSH...${END}"
  chsh -s "$(which zsh)"
fi

# ===============================
# Final
# ===============================
echo -e "${GREEN}"
echo "[+] Dotfiles instalados correctamente"
echo "[+] Reinicia la terminal o el sistema"
echo "${END}"
