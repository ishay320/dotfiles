#!/bin/bash
# reason:
# this is a fix for when returning from sleep go back to sleep
#
# side effects:
# sometimes need to switch tty (ctrl+alt+F5) for the other screens to work again

echo "Patching /usr/bin/nvidia-sleep.sh to fix nvidia sleep issue..."
# add # to every line that contains 'chvt'
sudo sed -i '/chvt/s/^/#/' /usr/bin/nvidia-sleep.sh
