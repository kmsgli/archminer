#!/bin/bash

echo "Updating system"
Pacman -Syu

echo "Installing software"
Pacman -S nvidia nvidia-settings conky


#####################################################################################################


#get user input
echo "Lets gathering some data"
sleep 1s

echo "What is your Username?"
read name

echo "What is your wallet number?"
read wallet

echo "Choose a rig name"
read rigname

echo "what is the pool website?"
read pool

echo "github package link? (right click and copy link for the latest linux release from https://github.com/ethereum-mining/ethminer/releases)"
read ethminer

echo "what is the git hub package to untar (ex. ethminer-0.15.0rc1-Linux.tar.gz)"
read tarball

echo "Lets get your gpu settings"
sleep 1s

echo "What would you like to set fan speed in percentage to? (ex. for 80 percent fan speed type 80)"
read fan

echo "What would you like to set graphics clock offset to? (ex. for a 1060's run -100)"
read offset

echo "What would you like to set the clock speed to? (ex for 1060 run 1400)"
read speed

echo "What would you like to set the max power in watts to? (ex for 90 watts type 90)"
read power

echo "Done gathering data"
sleep 1s

#####################################################################################################

echo "Making folders"
mkdir /home/$name/ethminer
cd /home/$name/ethminer

echo "Fethcing github package and unpacking"
#getting latest ethminer release
wget $ethminer

#unpack ethminer release
tar -xvf $tarball

#remove extra files
rm $ethminer

######################################################################################################

#Systemd files 
echo "Creating systemd/Desktop autostart services"

#create ethminer start systemd file
echo "[Unit]
Description=Ethereum Miner Process
Requires=multi-user.target
After=multi-user.target

[Service]
User=$name
Type=simple
WorkingDirectory=/home/$name/ethminer/bin
PermissionsStartOnly=true
ExecStart=/home/$name/ethminer/startminer.sh 
Restart=on-failure

[Install]
WantedBy=default.target" > ethminer.serivce


#create checkminer systemd file
echo "[Unit]
Description=Miner Status Check
Requires=multi-user.target
After=multi-user.target

[Service]
User=archminer
Type=oneshot
ExecStart=/bin/bash /home/archminer/ethminer/checkminer.sh


[Install]
WantedBy=default.target" > checkminer.service

#create checkminer systemd timer 
echo "[Unit]
Description=Run checkminer

[Timer]
OnBootSec=15min
OnUnitActiveSec=10min

[Install]
WantedBy=timers.target" > checkminer.timer


#create gpu settings autostart desktop file

echo "[Desktop Entry]
Type=Application
Exec=/home/archminer/ethminer/gputuner.sh
X-GNOME-Autostart-enabled=true
Name=nvidia-fan-speed" > nvidia.desktop

echo "[Desktop Entry]
Type=Application
Name=conky
Exec=conky --daemonize --pause=5
StartupNotify=false
Terminal=false" > conky.desktop

sleep 1s

####################################################################################################

#Making .sh files for systemd to command
echo "Creating shell scripts"
sleep 1s

#Take input information and make a shell scrpt to run ethminer command for systemd to use on boot
echo "Creating shell script to start ethminer"
echo "#!/bin/bash
/home/$name/ethminer/bin/ethminer -U --farm-recheck 200 -P stratum1+tcp://$wallet@$pool/$rigname" > startminer.sh

#Take input information and make a shell scrpt to change GPU settings for systemd to use on boot
echo "Creating shell script to set GPU settings"
echo "#!/bin/bash
#set fan speeds
nvidia-settings -a [gpu:0]/GPUFanControlState=1
nvidia-settings -a [fan:0]/GPUTargetFanSpeed=$fan

nvidia-settings -a [gpu:1]/GPUFanControlState=1
nvidia-settings -a [fan:1]/GPUTargetFanSpeed=$fan

nvidia-settings -a [gpu:2]/GPUFanControlState=1
nvidia-settings -a [fan:2]/GPUTargetFanSpeed=$fan

nvidia-settings -a [gpu:3]/GPUFanControlState=1
nvidia-settings -a [fan:3]/GPUTargetFanSpeed=$fan

nvidia-settings -a [gpu:4]/GPUFanControlState=1
nvidia-settings -a [fan:4]/GPUTargetFanSpeed=$fan

nvidia-settings -a [gpu:5]/GPUFanControlState=1
nvidia-settings -a [fan:5]/GPUTargetFanSpeed=$fan


# set gpu offest 
nvidia-settings -a [gpu:0]/GPUGraphicsClockOffset[3]=$offset

nvidia-settings -a [gpu:1]/GPUGraphicsClockOffset[3]=$offset

nvidia-settings -a [gpu:2]/GPUGraphicsClockOffset[3]=$offset

nvidia-settings -a [gpu:3]/GPUGraphicsClockOffset[3]=$offset

nvidia-settings -a [gpu:4]/GPUGraphicsClockOffset[3]=$offset

nvidia-settings -a [gpu:5]/GPUGraphicsClockOffset[3]=$offset


#set gpu clock speed
nvidia-settings -a [gpu:0]/GPUMemoryTransferRateOffset[3]=$speed

nvidia-settings -a [gpu:1]/GPUMemoryTransferRateOffset[3]=$speed 

nvidia-settings -a [gpu:2]/GPUMemoryTransferRateOffset[3]=$speed

nvidia-settings -a [gpu:3]/GPUMemoryTransferRateOffset[3]=$speed

nvidia-settings -a [gpu:4]/GPUMemoryTransferRateOffset[3]=$speed

nvidia-settings -a [gpu:5]/GPUMemoryTransferRateOffset[3]=$speed



#set power limits

sudo nvidia-smi -i 0 -pl $power

sudo nvidia-smi -i 1 -pl $power

sudo nvidia-smi -i 2 -pl $power

sudo nvidia-smi -i 3 -pl $power

sudo nvidia-smi -i 4 -pl $power

sudo nvidia-smi -i 5 -pl $power" > gputuner.sh


#making checktimer.sh
echo "#!/bin/bash
SERVICE=ethminer.service

if (! systemctl -q is-active $SERVICE)
   then
   sudo systemctl restart $SERVICE
   python /home/$name/ethminer/miner_pushover.py

fi
exit 0" > checktimer.sh


#giving shell scripts execution privelages
chmod +x gputuner.sh
chmod +x startminer.sh
chmod +x checkminer.sh

######################################################################################


#Move systemd services to systemd folder
echo "Moving files and automating system"

#Moving systemd files
sudo mv ethminer.service /etc/systemd/system
sudo mv checkminer.service /etc/systmed/system
sudo mv checkminer.timer /etc/systemd/system

#Moving desktop auto start files
mv nvidia.desktop /home/$name/.config/autostart
mv conky.desktop /home/$name/.config/autostart

#Moving conky config file
mv ~/conkyconfig /home/$name/.conkyrc
sleep 1s

#Enable systemd files on reboot"
sudo systemctl enable ethminer.service
sudo systemctl enable checkminer.timer
sleep 1

echo "Run nvidia-xonfig to enable coolbits for all GPUS"
sudo nvidia-xconfig -a --cool-bits=28 --allow-empty-initial-configuration
sleep 1s

#####################################################################################

echo "Creating shortcut commands"

#creating bash alias shortcuts
echo "alias showminer='journalctl -u ethminer -f'
alias startminer='sudo systemctl start ethminer.service'
alias stopminer='sudo systemctl stop ethminer.service'
alias showstats='nvidia-smi -a'
export EDITOR='nano'" >> /home/$name/.bashrc
#####################################################################################
echo "showminer = watch ethminer real time"
echo "showstats = show full specs for all GPUS (use | grep to narrow down results ex. showstats | grep Power)"
echo "stopminer = stop the miner (it will auto start on boot)"
echo "Done!"
