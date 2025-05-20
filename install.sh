#!/usr/bin/env bash

set -e

print_usage() {
  echo "Usage: $0 [-i | --install] [-u | --update]"
  echo "  -i, --install   Run interactive installation"
  echo "  -u, --update    Update Neovim and fzf silently"
  exit 1
}

if [[ $# -eq 0 ]]; then
  print_usage
fi

MODE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--install) MODE="install"; shift ;;
    -u|--update)  MODE="update"; shift ;;
    *) echo "Unknown option: $1"; print_usage ;;
  esac
done

### OS DETECTION AND SYSTEM PACKAGE INSTALLATION (only for install mode) ###

install_system_packages() {
  echo "Detecting OS..."

  if [ -f /etc/os-release ]; then
    . /etc/os-release
  else
    echo "Cannot detect OS. Exiting."
    exit 1
  fi

  confirm_install() {
    echo "The following packages will be installed:"
    for pkg in "$@"; do
      echo "  - $pkg"
    done
    echo -n "Do you want to continue? [Y/n]: "
    read -r answer
    case "$answer" in
      [Nn]*) echo "Installation cancelled."; return 1 ;;
      [Yy\n]*|"") return 0 ;;
      *) echo "Input error"; confirm_install "$@"; return $? ;;
    esac
  }

  install_ubuntu() {
    local pkgs=(zip wget curl ripgrep build-essential)
    echo "Updating apt package lists..."
    sudo apt update
    if confirm_install "${pkgs[@]}"; then
      sudo apt install -y "${pkgs[@]}"
    else
      return 0
    fi
  }

  install_arch() {
    local pkgs=(zip wget curl ripgrep base-devel)
    echo "Updating pacman database..."
    sudo pacman -Sy --noconfirm
    if confirm_install "${pkgs[@]}"; then
      sudo pacman -S --needed --noconfirm "${pkgs[@]}"
    else
      return 0
    fi
  }

  case "$ID" in
    ubuntu|debian) install_ubuntu ;;
    arch) install_arch ;;
    *)
      echo "Unsupported OS: $ID"
      echo "Install zip, wget, curl, ripgrep, and build tools manually."
      exit 1
      ;;
  esac
}

### NEOVIM INSTALLATION / UPDATE ###

install_or_update_nvim() {
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64) NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.appimage" ;;
    aarch64) NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-arm64.appimage" ;;
    *)
      echo "Unsupported architecture: $ARCH"
      exit 1
      ;;
  esac

  if [[ "$MODE" == "install" && -x "$(command -v nvim)" ]]; then
    echo "Neovim is already installed at $(command -v nvim)"
    read -p "Reinstall / Update? ([Y]/n): " response
    response=${response,,}
    if [[ "$response" == "n" ]]; then
      echo "Skipping Neovim installation."
      return
    fi
  fi

  echo "Installing/Updating Neovim..."
  curl -sSfLO "$NVIM_URL"
  chmod u+x nvim-linux-*.appimage
  sudo mv nvim-linux-*.appimage /usr/local/bin/nvim
  echo "Neovim installed/updated successfully."
}

### FZF INSTALLATION / UPDATE ###

install_or_update_fzf() {
  if [ -d "$HOME/.fzf" ]; then
    echo "fzf already exists. Updating..."
    cd ~/.fzf && git pull
    if [[ "$MODE" == "install" ]]; then
      ./install
    else
      yes | ./install --all > /dev/null
    fi
  else
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    if [[ "$MODE" == "install" ]]; then
      ~/.fzf/install --no-bash
    else
      yes | ~/.fzf/install --no-bash  > /dev/null
    fi
  fi
  echo "fzf installed/updated successfully."
}

### MAIN EXECUTION FLOW ###

if [[ "$MODE" == "install" ]]; then
  install_system_packages

  read -p "Install Neovim? ([Y]/n): " yn
  yn=${yn,,}
  if [[ "$yn" != "n" ]]; then
    install_or_update_nvim
  fi

  read -p "Install fzf? ([Y]/n): " yn
  yn=${yn,,}
  if [[ "$yn" != "n" ]]; then
    install_or_update_fzf
  fi

elif [[ "$MODE" == "update" ]]; then
  install_or_update_nvim
  install_or_update_fzf
fi

echo "Done."

