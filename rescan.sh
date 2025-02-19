sudo bash -c 'echo 1 > /sys/bus/pci/devices/0000\:01\:00.0/remove' && \
sleep 2 && \
sudo bash -c 'echo 1 > /sys/bus/pci/rescan'