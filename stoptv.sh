#!/bin/bash

if pgrep -x 'mpv' > /dev/null && pgrep -x 'tvstation.sh' > /dev/null && pgrep -x 'overlay' > /dev/null; then
        TV_PID=$(pgrep -x 'tvstation.sh')
        MPV_PID=$(pgrep -x 'mpv')
        OVRLY_PID=$(pgrep -x 'overlay')
        kill -9 $TV_PID
        kill -9 $MPV_PID
        kill -9 $OVRLY_PID
        echo "TVStation: OFF"
else

if ! pgrep -x 'mpv' > /dev/null && ! pgrep -x 'tvstation.sh' > /dev/null && ! pgrep -x 'overlay' > /dev/null; then
echo "TVStation: Not Running"
else
        if pgrep -x 'mpv' > /dev/null; then
                MPV_PID=$(pgrep -x 'mpv')
                kill -9 $MPV_PID
                echo "MPV: KILLED"
        else
                echo "MPV: Not running"
        fi



        if pgrep -x 'tvstation.sh' > /dev/null; then
                TV_PID=$(pgrep -x 'tvstation.sh')
                MPV_PID=$(pgrep -x 'mpv')
                kill -9 $TV_PID
                echo "TV Script: KILLED"
        else
                echo "TV Script: Not running"
        fi

        if pgrep -x 'overlay' > /dev/null; then
                OVRLY_PID=$(pgrep -x 'overlay')
                kill -9 $OVRLY_PID
                echo "Overlay: KILLED"
        else
                echo "Overlay: Not Running"
        fi

        if pgrep -f 'ifmpvnotrunning.sh' > /dev/null; then
                FAILSAFE_PID=$(pgrep -f 'ifmpvnotrunnning.sh')
                kill -9 $FAILSAFE_PID
                echo "Failsafe Script: KILLED"
        else
                echo "Failsafe Script: Not Running"
        fi

        if pgrep -f 'chromium' > /dev/null; then
                CHROME_PID=$(pgrep -f 'chromium')
                kill -9 $CHROME_PID
                echo "Weather: KILLED"
        else
                echo "Weather: Not Running"
        fi
    fi
fi

pcmanfm --set-wallpaper $HOME/Pictures/please-stand-by.png --wallpaper-mode=stretch
