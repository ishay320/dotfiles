#!/usr/bin/env bash

# Exit on error and log all actions
set -e
exec > >(tee -i arch_installation.log)
exec 2>&1

echo "=== Arch Linux Installation Script ==="

configure_pacman() {
	echo "Configuring pacman settings..."
	sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
	sudo sed -i 's/#Color/Color/' /etc/pacman.conf
	sudo sed -i '/\[options\]/a ILoveCandy' /etc/pacman.conf

}

configure_gnome() {
	echo "Configuring GNOME settings..."
	# fix for vscode
	gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close
	gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up "['']"
	gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down "['']"

	# Custom keybindings
	gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'terminal'
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'ghostty'
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Control><Alt>t'

	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'copyq'
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'copyq show'
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Super>v'

	# Fix for copyq shortcut
	gsettings set org.gnome.shell.keybindings toggle-message-tray "['']"
}

configure_xdg() {
	echo "Configuring xdg-open defaults..."
	xdg-mime default org.gnome.Nautilus.desktop inode/directory
	xdg-mime default nvim.desktop application/x-shellscript
	xdg-mime default nvim.desktop text/plain
}

configure_services() {
	echo "Enabling and starting services..."
	sudo systemctl enable bluetooth.service
	sudo systemctl start bluetooth.service
}

update_man_db() {
	echo "Updating man database..."
	sudo mandb
}

set_custom_fonts() {
	echo "Setting custom font (FiraMono Nerd Font)..."
	gsettings set org.gnome.desktop.interface monospace-font-name 'FiraMono Nerd Font Mono 10'
}

configure_pacman
configure_gnome
configure_xdg
configure_services
update_man_db
set_custom_fonts
echo "Installation and configuration complete!"
