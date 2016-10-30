#!/bin/bash
echo -e "\e[93m###################################\e[0m"
echo -e "\e[93m# Minera V7.0 on BeagleBone Black #\e[0m"
echo -e "\e[93m#        Full installation        #\e[0m"
echo -e "\e[93m# V1.2 by Wareck wareck@gmail.com #\e[0m"
echo -e "\e[93m###################################\e[0m"
echo 

echo -e "\e[92mKilling default webserver and webservices...\e[0m"
systemctl disable bonescript-autorun.service
systemctl disable cloud9.service
systemctl disable gateone.service
systemctl disable bonescript.service
systemctl disable bonescript.socket
systemctl disable bonescript-autorun.service
systemctl disable avahi-daemon.service
systemctl disable gdm.service
systemctl disable mpd.service
rm -r -f /var/www/html

echo
echo -e "\e[92mCleaning ...\e[0m"
apt-get remove lightdm -y -qq
apt-get remove lxqt-* xserver* apache2 chromium-browser apache2-utils qtcore4-l10n --purge -y -qq
apt-get remove apache2-* adwaita-icon-theme tightvncserver --purge -y
apt-get autoremove -y -qq
sed -i -e "s|iface usb0 inet static||" /etc/network/interfaces
sed -i -e "s|address 192.168.7.2||" /etc/network/interfaces
sed -i -e "s|netmask 255.255.255.252||" /etc/network/interfaces
sed -i -e "s|network 192.168.7.0||" /etc/network/interfaces
sed -i -e "s|gateway 192.168.7.1||" /etc/network/interfaces

echo
echo -e "\e[92mPerforming : Update...\e[0m"
apt-get update

echo
echo -e "\e[92mPerforming install - lighttpd & php ...\e[0m"
sudo apt-get install -y lighttpd php5-cgi
sudo lighty-enable-mod fastcgi
sudo lighty-enable-mod fastcgi-php
sudo service lighttpd force-reload
sudo apt-get install -y redis-server git screen php5-cli php5-curl -qq

echo
echo -e "\e[92mPerforming install - building tools for miner ...\e[0m"
apt-get install build-essential libtool libcurl4-openssl-dev libjansson-dev -y
apt-get install udev libudev-dev automake autoconf -y

echo
echo -e "\e[92mPerforming : CPU_temp installation...\e[0m"
git clone https://github.com/asmagill/am335x_bandgap.git /root/am335x_bandgap
cd /root/am335x_bandgap
make

echo
echo -e "\e[92mPerforming : Kernel patching...\e[0m"
sed -i -e "s|GOVERNOR="ondemand"|GOVERNOR="performance"|" /etc/init.d/cpufrequtils

kversion=`uname -r`
apt-get install linux-headers-$kversion
cd /boot/dtbs/$kversion/
dtc -I dtb -O dts am335x-boneblack.dtb > /tmp/am335x-boneblack.dts
patch -p0 /tmp/am335x-boneblack.dts < /root/am335x_bandgap/bandgap.patch
dtc -O dtb -o /tmp/am335x-boneblack.dtb -b 0 /tmp/am335x-boneblack.dts
cp /boot/dtbs/$kversion/am335x-boneblack.dtb /boot/dtbs/$kversion/am335x-boneblack.dtb.dist
cp /tmp/am335x-boneblack.dtb /boot/dtbs/$kversion/am335x-boneblack.dtb
cd
dkms install /root/am335x_bandgap

if grep -Fxq "am335x_bandgap" /etc/modules
then
    echo -e "\e[95mstring already present in /etc/modules\e[0m"
else
    echo "am335x_bandgap" >>/etc/modules
fi
sleep 3
rm -r -f /root/am335x_bandgap
sleep 3

echo
echo -e "\e[92mPerforming clonning Minera ...\e[0m"
cd /var/www
sudo git clone https://github.com/michelem09/minera
cd minera

echo
echo -e "\e[92mPerforming patching Minera (cpu temp) ...\e[0m"
sed -i -e "s|/sys/class/thermal/thermal_zone0/temp|/sys/class/hwmon/hwmon0/device/temp1_input|" /var/www/minera/application/config/app.php

echo
echo -e "\e[92mPerforming install Minera ...\e[0m"
./install_minera.sh

echo -e "\e[92mPerforming build miners ...\e[0m"
echo
./build_miner.sh bfgminer
rm -r -f bfgminer
./build_miner.sh cgminer
rm -r -f cgminer
./build_miner.sh cgminer-dmaxl
rm -r -f cgminer-dmaxl-zeus
./build_miner.sh cpuminer
rm -r -f cpuminer-gc3355

clear
echo -e "\e[92mFinishing install ...\e[0m"
userdel debian
sudo sed -i -e "s|debian  ALL=NOPASSWD: ALL|minera  ALL=NOPASSWD: ALL|" /etc/sudoers
echo -e "\e[91mYou need to change ROOT password then reboot BeagleBone to use Minera\e[0m"
echo -e "\e[93mPlease choose new password for ROOT:\e[0m"
passwd

_IP=$(hostname -I | sed 's/............$//')
echo
echo -e "\e[93mAfter restarting you can go to \e[92mhttp://" $_IP "\e[0m\e[93m for web interface"
echo -e "\e[93mAnd default user/password for SSH are minera minera\e[0m"
echo
echo -e "\e[92mHappy mining !!!!\e[0m"
echo
echo -e "\e[92mwareck@gmail.com\e[0m"
echo
echo -e "\e[91mSystem will restart in few seconds ... please wait ...\e[0m"
sleep 15
init 6
