#!/bin/bash
# used commands

GameScript="$1"
	echo "Running $GameScript"


install_adb() {
    if command -v adb >/dev/null 2>&1; then
        echo "✔ adb installed"
        return
    fi

    echo "❌ adb missing, Installing..."

    if command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y android-tools-adb

    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y android-tools

    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm android-tools

    else
        echo "⚠️  can't install ADB"
        echo "Proceed manually"
        exit 1
    fi
}


#### check if waydroid is running ######
SERVICE="waydroid"
if pgrep -x "$SERVICE" >/dev/null
then
    echo "$SERVICE is running"
else
    echo "$SERVICE stopped"
    $SERVICE show-full-ui
fi

#### check port 5555 is open in Waydroid
$SERVICE shell <<'EOF' 
setprop service.adb.tcp.port 5555
stop adbd
start adbd
exit
EOF

adb connect 192.168.240.112:5555

#### check if ADB is running
SERVICE="adb"
if pgrep -x "$SERVICE" >/dev/null
then
    echo "$SERVICE is running"
else
    echo "$SERVICE stopped"
    adbd start
fi

LINE=$(adb shell wm size)
echo "test $LINE"
SIZE=${LINE#*: }
WIDTH=${SIZE%x*}
HEIGHT=${SIZE#*x}
HCENTER=WIDTH/2
VCENTER=HEIGHT/2
echo "WIDTH=$WIDTH HEIGHT=$HEIGHT"


while :
do
	source $GameScript
done
