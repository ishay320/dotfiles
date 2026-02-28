# if some of the windows are very small - xwayland-native-scaling can case problems. This can help
gsettings get org.gnome.mutter experimental-features

gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'variable-refresh-rate']"
