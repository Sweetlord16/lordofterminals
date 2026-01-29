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

# ===============================
# Wallpapers piolotes
# ===============================
echo -e "\n${BLUE}[*] Configurando wallpapers...${END}"
sleep 2

dir="$HOME/lordofterminals"
WALL_DIR="$HOME/Wallpapers"

mkdir -p "$WALL_DIR"
cp -rv "$dir/wallpapers/"* "$WALL_DIR/"

# Crear / setear wallpaper (XFCE Kali)
xfconf-query -c xfce4-desktop \
--create \
-p /backdrop/screen0/monitorVirtual1/workspace0/last-image \
-t string \
-s "$WALL_DIR/The Oni.jpg"

xfdesktop --reload

echo -e "\n${GREEN}[+] Wallpapers configurados${END}"
sleep 1.5




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

sudo rm /usr/bin/qterminal      
sudo ln -s /usr/bin/kitty /usr/bin/qterminal




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
