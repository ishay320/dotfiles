#!/usr/bin/env bash

set -e

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
    *) echo "Input error";  confirm_install "$@"; return $?;;
  esac
}

install_ubuntu() {
  local pkgs=(zip wget curl ripgrep build-essential)
  echo "Updating apt package lists..."
  sudo apt update

  if confirm_install "${pkgs[@]}"; then
    sudo apt install -y "${pkgs[@]}"
  else
    exit 0
  fi
}

install_arch() {
  local pkgs=(zip wget curl ripgrep base-devel)
  echo "Updating pacman database..."
  sudo pacman -Sy --noconfirm

  if confirm_install "${pkgs[@]}"; then
    sudo pacman -S --needed --noconfirm "${pkgs[@]}"
  else
    exit 0
  fi
}

case "$ID" in
  ubuntu|debian)
    install_ubuntu
    ;;
  arch)
    install_arch
    ;;
  *)
    echo "Unsupported OS: $ID"
    echo "You need to install zip, wget, curl, ripgrep, and build tools manually."
    exit 1
    ;;
esac

echo "Installation completed."

