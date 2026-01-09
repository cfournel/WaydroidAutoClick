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
        sudo apt install -y android-tools-adb imagemagick

    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y android-tools imagemagick

    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm android-tools imagemagick

    else
        echo "⚠️  can't install ADB"
        echo "Proceed manually"
        exit 1
    fi
}

take_screenshot()
{
    adb shell screencap -p /sdcard/screenshot.png
    adb pull /sdcard/screenshot.png /tmp/screenshot.png
    adb shell rm /sdcard/screenshot.png
}

find_image()
{
    take_screenshot
    screen="/tmp/screenshot.png"

    out=$(compare -metric NCC -subimage-search "$screen" "$1" "diff.png" null: 2>&1)

    score=$(echo "$out" | awk '{print $1}')
    pos=$(echo "$out" | awk -F'@ ' '{print $2}')

    echo "score=$score"
    echo "pos=$pos"
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
PAUSE=0
echo "WIDTH=$WIDTH HEIGHT=$HEIGHT"


while :
do
	read -t2 -n1 check
#	if ([ $check != "" ]  && [ PAUSE==0]); then
#	        echo "Paused"
#		PAUSE==1
#        	read -n1
#	        check=""
#	fi
#	if ([ $check != ""] && [PAUSE==1]); then
#		echo "Resume"
#		PAUSE=0
#	fi
    	if ([ $PAUSE == 0 ]); then
		source $GameScript
	fi
done
