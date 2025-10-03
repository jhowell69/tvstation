#! /bin/bash

if pgrep -x 'overlay' > /dev/null; then
        kill -9 $(pgrep -x overlay)
        echo "Logo Overlay: KILLED"
else
        echo "Logo Overlay not running."
fi
