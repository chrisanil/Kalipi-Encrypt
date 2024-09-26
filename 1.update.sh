# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

apt update
apt full-upgrade --autoremove -y
#sudo rpi-update
echo "Done. Reboot with: sudo reboot"
#reboot #needed to load new kernel
