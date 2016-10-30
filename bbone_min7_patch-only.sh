#!/bin/bash
echo -e "\e[93m###################################\e[0m"
echo -e "\e[93m# Minera V7.0 on BeagleBone Black #\e[0m"
echo -e "\e[93m#           Patch only            #\e[0m"
echo -e "\e[93m# V1.2 by Wareck wareck@gmail.com #\e[0m"
echo -e "\e[93m###################################\e[0m"

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
	echo "String already present in /etc/modules "
else
	echo "am335x_bandgap" >>/etc/modules
fi
sleep 3
rm -r -f /root/am335x_bandgap
sleep 3


if [ -f /var/www/minera/application/config/app.php ]
  then
	echo
	echo -e "\e[92mPerforming : patching Minera (cpu temp) ...\e[0m"
	sed -i -e "s|/sys/class/thermal/thermal_zone0/temp|/sys/class/hwmon/hwmon0/device/temp1_input|" /var/www/minera/application/config/app.php

	echo
	echo -e "\e[92mPerforming : install pre-compiled miner for BeagleBone ...\e[0m"
	cd /var/www/minera/minera-bin/
	curl https://raw.githubusercontent.com/wareck/minera7.0_on_beaglebone/master/precomp_miners.tar.xz | tar xJ

  else
	echo
	echo -e "\e[91mMinera seems to not be well installed \e[0m"
	echo -e "\e[91mPlease install it manualy as explain in Minera website : https://getminera.com/ \e[0m"
	echo -e "\e[91mOr use my other script ./beagle_minera.sh \e[0m"
	echo
	exit
fi
echo
echo -e "\e[92m...done.\e[0m"
