# install chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

# fix the clock desync
timedatectl set-local-rtc 0

# install vscode
sudo snap install --classic code
{ # fix for multi cursor vscode
	# the old way
	gsettings set org.gnome.shell.keybindings move-to-workspace-up "[]"
	gsettings set org.gnome.shell.keybindings move-to-workspace-down "[]"
	# or if they fail:
	gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up "[]"
	gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down "[]"
	echo "Check that the 'ctrl + alt + shift + up/down' hase been removed"
}

echo "Download the newest in https://github.com/hluk/CopyQ"
# sudo apt install copyq -y
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>m']"
echo "Don't forget to go to copyq setting and add 'super + v' shortcut and autostart"
echo "You need to fix the autostart :  in ~/.config/autostart/copyq.desktop: Exec=env QT_QPA_PLATFORM=xcb copyq"
