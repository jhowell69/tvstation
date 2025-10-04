#! /bin/bash

ONLINE_OR_NOT_FILE="/tmp/amionline.bool"

if [ ! -f "$ONLINE_OR_NOT_FILE" ]; then
  touch $ONLINE_OR_NOT_FILE
fi

IP=$(ping -c 1 "$ONLINE_CHECKER" | grep -oP '(?<=\().*?(?=\))')


# == Check to see if system is online or not ===
if [[ $IP != *192.168.* && $IP != *10.0.0.* && $IP != *"No address"* ]]; then
        echo "true" > "$ONLINE_OR_NOT_FILE"
else
        echo "false" > "$ONLINE_OR_NOT_FILE"
fi

ONLINE_OR_NOT=$(<"$ONLINE_OR_NOT_FILE")

# == Play weather update. You can go on this website and enable sound and kiosk mode. If you enable sticky kiosk, when future weather updates start, it will start fullscreen with sound. CTRL+K to escape kiosk mode ==
if [[ "$ONLINE_OR_NOT" == "true" && "$ENABLE_WEATHERANDTIMEBUMPER" == "true" ]]; then
        chromium-browser --kiosk -autoplay-policy=no-user-gesture-required https://weatherstar.netbymatt.com/ &
        sleep 1
        kill -9 $(pgrep -x 'chromium')
else
        echo "Device offline or weather update disabled. Skipping live weather update"
fi
