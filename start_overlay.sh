#! /bin/bash

# == Create logo overlay process only if it isn't running
if ! pgrep -x 'overlay' > /dev/null; then
        ~/overlay &
        echo "Logo Overlay: Started"
else
        echo "Logo Overlay: already running."
fi
