#!/bin/bash

# nvim

install_nvim() {
	# Detect system architecture
	ARCH=$(uname -m)
	case "$ARCH" in
	x86_64) NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.appimage" ;;
	aarch64) NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-arm64.appimage" ;;
	*)
		echo "Unsupported architecture: $ARCH"
		exit 1
		;;
	esac

	# Check if Neovim is already installed
	if command -v nvim >/dev/null; then
		echo "Neovim is already installed at $(command -v nvim)"
		read -p -r "Reinstall / Update? ([Y]/n): " response
		response=${response,,} # Convert to lowercase
		if [[ "$response" == "n" ]]; then
			echo "Skipping installation."
			return
		fi
	fi

	# Download and install Neovim
	echo "Downloading Neovim for $ARCH..."
	curl -sSfLO "$NVIM_URL"
	chmod u+x nvim-linux-*.appimage
	sudo mv nvim-linux-*.appimage /usr/local/bin/nvim

	echo "Neovim installed successfully."
}

read -p -r "Install Neovim? ([Y]/n): " response
response=${response,,} # Convert to lowercase
if [[ "$response" != "n" ]]; then
	install_nvim
fi

# fzf
if [ -f "$HOME/.fzf" ]; then
	cd ~/.fzf && git pull && ./install
else
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
fi
