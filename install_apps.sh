#!/bin/bash

# nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
sudo mv ./nvim.appimage /usr/local/bin/nvim

# fzf
if [ -f "$HOME/.fzf" ]; then
    cd ~/.fzf && git pull && ./install
else
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi
