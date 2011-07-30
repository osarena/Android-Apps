#!/bin/bash

##################################################
# Automated mount: Asus Transformer > Linux Mint #
#                                                #
# author: Steve B                                #
# Revision date:   June 28 2011                  #
##################################################

#####################################################################################################################
# Original step-by-step instructions:                                                                               #
# http://www.acertabletforum.com/forum/acer-iconia-tab-general-discussions/129-connecting-via-usb-linux-ubuntu.html #
#####################################################################################################################

sudo apt-get install mtpfs ;

configUser=`whoami` ;
configGroup=`id -g $configUser` ;
vendorId=`lsusb | grep -i asus | cut -d' ' -f 6 | cut -d: -f 1` ;

######################
# Create mount point #
######################

echo "Creating mount point" ;
sudo mkdir /media/transformer ;
sudo chown $configUser:$configGroup /media/transformer ;

######################
# Edit android.rules #
######################

echo "Backing up android.rules" ;
sudo cp -vp /etc/udev/rules.d/51-android.rules /etc/udev/rules.d/51-android.rules.`date +%d%m%Y-h%Hm%Ms%S`.bak ;

if grep -i $vendorId /etc/udev/rules.d/51-android.rules ; 
then 
	echo "android.rules already configured. Skipping.";
else
	echo "android.rules not configured";
	echo "Configuring...";
	sudo chmod 777 /etc/udev/rules.d/51-android.rules ; 
	sudo echo "SUBSYSTEM==\"usb\", ATTR{idVendor}==\"$vendorId\", MODE=\"0666\"" >> /etc/udev/rules.d/51-android.rules ; 
	sudo chmod 644 /etc/udev/rules.d/51-android.rules ;
fi

##############
# Edit fstab #
##############

echo "Backing up /etc/fstab" ;
sudo chmod 777 /etc/fstab ;
sudo cp -vp /etc/fstab /etc/fstab.`date +%d%m%Y-h%Hm%Ms%S`.bak ;

if grep -i "/media/transformer" /etc/fstab ; 
then 
	echo "fstab already configured with a /media/transformer mount point. Skipping...";
else
	echo "fstab not configured";
	echo "Configuring...";
	sudo echo "# mount point for Asus Transformer" >> /etc/fstab ;
	sudo echo "mtpfs     /media/transformer     fuse     user,noauto,allow_other      0      0" >> /etc/fstab ;
fi

sudo chmod 644 /etc/fstab ;

##################
# Edit fuse.conf #
##################

# backup original fuse.conf file
sudo cp -vp /etc/fuse.conf /etc/fuse.conf.`date +%d%m%Y-h%Hm%Ms%S`.bak ;

# uncomment "user_allow_other" line
sudo sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf ;

##########################
# add user to fuse group #
##########################

echo "Backing up /etc/group" ;
sudo cp -vp /etc/group /etc/group.`date +%d%m%Y-h%Hm%Ms%S`.bak ;

if cat /etc/group | grep fuse | grep $configUser ; 
then 
	echo "$configUser already configured into fuse group";
	 
else 
	echo "Adding $configUser to fuse group" ;
	sudo usermod -a -G fuse $configUser ;
fi 



