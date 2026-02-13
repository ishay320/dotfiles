#!/usr/bin/env bash
set -e

BASE_PACKAGES_FOLDER="./packages/"

install_arch() {
  local pkgs_file_path="$BASE_PACKAGES_FOLDER/packages.arch"
  for pkg in $(cat "$pkgs_file_path"); do
    if [[ $pkg == https://* ]]; then
      echo "Installing AUR package from $pkg"
      git clone "$pkg" /tmp/aur_pkg
      (cd /tmp/aur_pkg && makepkg -si --noconfirm)
      rm -rf /tmp/aur_pkg
    elif [[ $pkg == aur* ]]; then
      echo "Installing AUR package $pkg via yay"
      yay -S --noconfirm --needed "$pkg"
    else
      echo "Installing package $pkg via pacman"
      sudo pacman -S --noconfirm --needed "$pkg"
    fi
  done
}

install_ubuntu() {
  local pkgs_file_path="$BASE_PACKAGES_FOLDER/packages.ubuntu"
  # sudo apt update
  for pkg in $(cat "$pkgs_file_path"); do
    echo "Installing package $pkg via apt"
    # sudo apt install -y "$pkg"
  done
}

detect_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
  else
    echo "Cannot detect OS. Exiting."
    exit 1
  fi
}

install_nvim_appimage() {
  ARCH=$(uname -m)
  case "$ARCH" in
  x86_64) NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.appimage" ;;
  aarch64) NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-arm64.appimage" ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
  esac
  echo "Downloading Neovim..."
  curl -sSfLO "$NVIM_URL"
  chmod u+x nvim-linux-*.appimage
  sudo mv nvim-linux-*.appimage /usr/local/bin/nvim
  echo "Neovim installed successfully."
}

install_fzf_git() {
  if [ -d "$HOME/.fzf" ]; then
    echo "fzf already exists. Updating..."
    cd ~/.fzf && git pull
    yes | ./install --all >/dev/null
  else
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    yes | ~/.fzf/install --no-bash >/dev/null
  fi
  echo "fzf installed/updated successfully."
}

detect_os

case "$ID" in
ubuntu | debian)
  install_ubuntu
  install_nvim_appimage
  install_fzf_git
  ;;
arch)
  install_arch
  ./config_arch.sh
  ;;
*)
  echo "Unsupported OS: $ID"
  exit 1
  ;;
esac

# Configure git alias
git config --global alias.adog "log --all --decorate --oneline --graph --pretty=format:'%C(auto)%h%d %s %C(blue)<%an>%Creset %C(green)(%ar)%Creset'"

echo "Done."
