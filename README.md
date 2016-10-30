Minera v7.0 on BeagleBone
==============
Theses script make installation of Minera v7.0 on a BeagleBone.

Installation of Minera is about 99.9% as original files.

Only Kernel is patched and one line in Minera just for allowing CPU temp. mesurment.

Other lines are only to shrink installation and install some specific paquet for BeagleBone.

full Install script :
---------------------

Before start you need at least a 4GB scard.

Donwload lastest BeagleBone image from BB website.

Decompress/install it as explain on BB website.

Login as root (root and no password)

Expand your sdcard ( http://dev.iachieved.it/iachievedit/expanding-your-beaglebone-microsd-filesystem )

install code :

	git clone https://github.com/wareck/minera7.0_on_beaglebone
	cd minera7.0_on_beaglebone
	./bbone_min7_full.sh

And follow install process.

After install finished you need to reboot your BeagleBone.

Patch only script:
------------------

This scrypt will patch already installed minera on BeagleBone.

It enable CPU temp. mesurement, and install miners software already precompiled for BeagleBone.

install code :

	git clone https://github.com/wareck/minera7.0_on_beaglebone
	cd minera_7.0_on_beaglebone
	./bbone_min7_patch-only.sh
    
Prebuild image : 
----------------

If you don't want to use scripts files and build yourself image, you can donwload it here :

https://mega.nz/#!pt8w2TAJ!YcwoIr7GH74b24dOY09CeyzAeata7Ihid9euR7Hk6TQ

Build from:

* SDcard 4GB (minimum you can use larger)
* BeagleBone Black (works on BeagleBone black,green,white,green wireless, black industrial, Arrow, Mentorel , SanCloud)
* Debian 8.5 lxqt image (2016-13-05)
* Minera v7.0 (from github)
* Miners software update (rebuild on BeagleBone)
* Kernel patch for CPU temperature
* Cleaning


Happy Mining !

wareck
