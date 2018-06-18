# archminer
Setup script for Arch Linux ethminer (nvidia)
This is a script to streaminline setting up ethminer on an archlinux install.  
This script will also use pacman to install nvidia drivers nvidia-settings and conky for a desktop display.
The GPU settings are for NVIDIA GPU's (setups for Nvidia 1060's), should work for 1070's and 1080's.
It will gather user data to create config files systemd startup files and a method to check the miner perodically to ensure it has not crashed
Setup will include desktop autostart files to run the gpu tuner settings.
This was setup around the LXDE desktop environmet.  It may work with other Desktop environment's but proceed at your own risk.
Download and unzip the setupminer.zip and run ./setup.sh
Ensure you run setup.sh in the users home directory and do not run with sudo, it will be asked of you midway through the script.
I have not done extensive testing on this so proceed with caution and read through the script to make sure it makes sense for your system.

