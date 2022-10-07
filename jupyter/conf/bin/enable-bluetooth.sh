#! /bin/bash

# enable bluetooth for user 'iot'

host_ip=`ip route | grep 172.1 | awk '{print $NF}'`
ssh -q -o 'StrictHostKeyChecking no' -p 22222 root@${host_ip} << 'EOF'

if [ -f /etc/dbus-1/system.d/bluetooth.conf ] \
&& ! grep -q '<policy user="iot">' /etc/dbus-1/system.d/bluetooth.conf
then
    echo add user iot to bluetooth.conf on host
    mount -o remount,rw /
    cd /etc/dbus-1/system.d
    cp /etc/passwd /etc/passwd.bak
    echo 'iot:x:1000:100::/home/iot:/bin/sh' >>/etc/passwd
    sed -i.bak 's|</busconfig>|  <policy user="iot"> \
    <allow own="org.bluez"/> \
    <allow send_destination="org.bluez"/> \
    <allow send_interface="org.bluez.GattCharacteristic1"/> \
    <allow send_interface="org.bluez.GattDescriptor1"/> \
    <allow send_interface="org.freedesktop.DBus.ObjectManager"/> \
    <allow send_interface="org.freedesktop.DBus.Properties"/> \
  </policy> \
</busconfig>|' bluetooth.conf
    mount -o remount,r /
fi
echo bluetooth enabled for user iot
EOF

