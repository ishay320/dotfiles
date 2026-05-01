# problem

if one of the screens set to more then 100% then wine and xwayland is rendered at x2 times smaller.

## fixes

1. make all the screens 100%

## not proven fixes

1. set:

   ```sh
   gsettings set org.gnome.mutter.wayland xwayland-scaling-factor 1.0
    # originally 0
   ```

2. remove 'xwayland-native-scaling':

   ```sh
    gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'xwayland-native-scaling']"
    # originally []
   ```
