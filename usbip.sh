#!/bin/bash
## EXIT 0 = Normal / EXIT 1 = USB HOST ERROR / EXIT 2 = OTHER SSH SESSION STILL OPEN / EXIT 3 = invalid aargument
_ARG=$1

STARTUP() {
if ! [[ -f /var/run/usbip.pid ]]; then
_CIP=`pinky -wf|awk '{print $5}'`
_IP=`echo $_CIP|cut -d' ' -f1`
  if nc -z $_IP 3240;then
        _BUS=`usbip list -r $_IP | grep [0-9]-[0-9]: | cut -d: -f1`
  else
        echo "usbip host not running"
        exit 1
  fi

  if [[ ! -z $_BUS ]]; then
        modprobe vhci-hcd
        usbip attach -r laptop -b $_BUS
        _EXIT=$?
        echo "Connected USB BUS $_BUS"
  fi

  if [[ $_EXIT == 0 ]]; then
        echo "Rescan udev rules"
        udevadm trigger
        echo $$ > /var/run/usbip.pid
  else
        echo "USB host not sharing ?"
        exit 1
  fi
echo " Remote USB available "
exit 0
fi
}

SHUTDOWN() {
if [[ -f /var/run/usbip.pid ]]; then
sudo rm /var/run/usbip.pid
#echo "`date` clean ssh exit"|sudo tee -a /var/log/ssh-logout.log
sudo usbip detach -p 00
sudo modprobe -r vhci-hcd
exit 0
fi
}

if ! [[ $_ARG == log* ]]; then
echo "Wrong argument"
exit 3
fi

if [[ $_ARG == login ]]; then
STARTUP
elif [[ $_ARG == logout ]] && [[ `ps aux|grep sshd|grep -v "grep sshd"|grep ^$(whoami)|wc -l` -le 1 ]]; then
SHUTDOWN
else
exit 2
fi
