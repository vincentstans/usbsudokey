Hello, 

We're going to use a usb flash drive to disable sudo password requests.
You can use any other usb device and you can use them how ever you like we only going to use the hardware id's
check udev.rules.sample how to setup your udev rules.
then put sudo.udev in place this should work for local machines. too expand over remote put shareusb on the local machine and 
sudo.udev / udev.rules.sample / bashrc.txt and usbip.sh on the remote server. or atleast the needed content. install usbip on both.

enjoy.
