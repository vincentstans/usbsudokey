#!/bin/bash
## This file should be in /usr/local/sbin/ of a remote ssh server
## This file should be executed by root chmod 4740 
## user should be able to run this script without sudo password! :$ sudo visudo -f /etc/sudoers.d/usbip 
## USERNAME ALL=NOPASSWD: /usr/local/sbin/usbip.sh
## Argument login or logout
_ARG=$1

## On Login do STARTUP
STARTUP() {
if ! [[ -f /var/run/usbip.pid ]]; then
modprobe vhci-hcd
## Client should have shareusb running
_IP=`pinky -wf|awk '{print $5}'`
_BUS=`usbip list -r $_IP | grep [0-9]-[0-9]: | cut -d: -f1`

if [[ ! -z $_BUS ]]; then
usbip attach -r $_IP -b $_BUS
_EXIT=$?
fi

if [[ $_EXIT == 0 ]]; then
udevadm trigger
fi

echo $$ > /var/run/usbip.pid
exit 0
fi
}

## On Logout run SHUTDOWN
SHUTDOWN() {
if [[ -f /var/run/usbip.pid ]]; then
sudo rm /var/run/usbip.pid
#echo "[`date`] -- clean ssh exit"|sudo tee -a /var/log/ssh-logout.log
sudo usbip detach -p 00
sudo modprobe -r vhci-hcd
exit 0
fi
}

if [[ $_ARG == login ]]; then
STARTUP
elif [[ $_ARG == logout ]] && [[ `ps aux|grep sshd|grep -v "grep sshd"|grep ^$(whoami)|wc -l` -le 1 ]]; then
SHUTDOWN
else
exit 2
fi
## exit 2 other ssh session still running
