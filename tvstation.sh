#!/bin/bash

# === This will wait until the desktop environment                                               ===
# === Comes online, otherwise there is a chance of a dialog box                                  ===
# === coming onscreen saying the desktop env isnt active.                                        ===
# === That box prevents the autostart of this script until user manually clicks that "OK" button ===
while ! pgrep -x "pcmanfm" > /dev/null; do
        echo "waiting on desktop environment to init..."
done

sleep 1

# === Exit mpv if active ===
if (( pgrep -f 'tvstation.sh' | wc -l )) > 1; then
        echo -e "Duplicate Instance of TVSTATION already running...\nRun stoptv to stop it, then re-run this script."
        exit 1
else
        echo "Starting TVSTATION. STANDBY..."
fi

export DISPLAY=:0
sleep 0.25
$HOME/standby.sh
sleep 0.25

# === Set starting volume ===
amixer sset Master 80%

# === Config options  ===
NUM_ADS=6                                       # Number of ads to play after episode is over

export ENABLE_WEATHERANDTIMEBUMPER=true         # Enable weather bumper that also shows time, only if internet is available
export ONLINE_CHECKER="amionline.net"

PLAYED_EPS_FILE="/tmp/played_episodes"       # Keep track of previously-played episodes
PLAYED_ADS_FILE="/tmp/played_ads"               # Keep track of previously-played ads
EPISODE_DIR="$HOME/Videos/tv"                   # Episodes (can be in subfolders)
ADS_DIR="$HOME/Videos/ads"                      # Ads folder
STATION_ID_DIR="$HOME/Videos/stationids"        # Folder containing station ID clips

# TODO
# === Holiday specials directory config ===
#ADS_DIR_HALOWEEN=
#ADS_DIR_CHRISTMAS=

# === touch played_* files ===
if [ ! -f "$PLAYED_ADS_FILE" ]; then
    touch "$PLAYED_ADS_FILE"
    echo "File created: $FILE"
fi

if [ ! -f "$PLAYED_EPS_FILE" ]; then
    touch "$PLAYED_EPS_FILE"
    echo "File created: $FILE"
fi


# === Pick a Random Station ID Upon script activation ===
station_ids=($(find "$STATION_ID_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.webm" \)))
RANDOM_ID="${station_ids[RANDOM % ${#station_ids[@]}]}"

echo ">>Playing station ID: $RANDOM_ID"
mpv --fs --video-unscaled=no --no-keepaspect "$RANDOM_ID"       # Play intro boot video

# == Play weather on my external docker server docker run -p 8002:8080 ghcr.io/netbymatt/ws4kp ==
~/weatherchannel.sh

# === Find All Episodes (Recursively) ===
mapfile -t all_eps < <(find "$EPISODE_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" \) | shuf)
mapfile -t all_ads < <(find "$ADS_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" \) | shuf)

# === Set background to black ===
blank

# === Play One Unseen Episode ===
start_Station() {

mapfile -t played_eps < "$PLAYED_EPS_FILE"
declare -A played_eps_map
for ep in "${played_eps[@]}"; do [[ -n "$ep" ]] && played_eps_map["$ep"]=1; done


# Filter out already played episodes
unique_eps=()
for ep in "${all_eps[@]}"; do
    if [[ -z "${played_eps_map["$ep"]}" ]]; then
        unique_eps+=("$ep")
        fi
done

# If no unique episodes left, reset the played file
if [[ ${#unique_eps[@]} -eq 0 ]]; then
    echo ">>All episodes have been played. Resetting episode history..."
    > "$PLAYED_EPS_FILE"
    # Rebuild episode list
    unique_eps=( "${all_eps[@]}" )
fi

# Play unique eps
ep_count=0
for ep in "${unique_eps[@]}"; do
    echo ">>Episode: $ad"
    mpv --fs --video-unscaled=no --no-keepaspect "$ep"
    echo "$ep" >> "$PLAYED_EPS_FILE"
    sleep 1
        ((ep_count++))
        if [[ $ep_count -ge 1 ]]; then
                break
        fi
done





# === Lower volume for Dragnet since audio peaks
if grep -q "Dragnet" "$ep"; then
        amixer sset Master 60%
else
        amixer sset Master 80%
fi

# === Turn up ad volume if it was turned down by Dragnet
amixer sset Master 80%

# == Play weather on my external docker server docker run -p 8002:8080 ghcr.io/netbymatt/ws4kp ==
~/weatherchannel.sh


# === Re-map played ads to only
mapfile -t played_ads < "$PLAYED_ADS_FILE"
declare -A played_ads_map
for ad in "${played_ads[@]}"; do [[ -n "$ad" ]] && played_ads_map["$ad"]=1; done

# == Play $(NUM_ADS) ads
echo ">> Playing $NUM_ADS unique ads..."
unique_ads=()
for ad in "${all_ads[@]}"; do
    if [[ -z "${played_ads_map["$ad"]}" ]]; then
        unique_ads+=("$ad")
    fi
done

# If no unique ads left, reset and restart
if [[ ${#unique_ads[@]} -eq 0 ]]; then
    echo ">>All ads have been played. Resetting ad history..."
    > "$PLAYED_ADS_FILE"
    # Rebuild ads list
    unique_ads=( "${all_ads[@]}" )
fi

# Play unique ads
ad_count=0
~/kill_overlay.sh
for ad in "${unique_ads[@]}"; do
        echo ">>Ad: $ad"
    mpv --fs --video-unscaled=no --no-keepaspect "$ad"
    echo "$ad" >> "$PLAYED_ADS_FILE"
    sleep 1
    ((ad_count++))
    if [[ $ad_count -ge $NUM_ADS ]]; then
                ~/start_overlay.sh
                break
        fi
done

# === Play weather if enabled ===
~/weatherchannel.sh

sleep 0.1
echo "END"
}

echo "GOTO start_Station"
while true;
do
        ~/start_overlay.sh
        start_Station
done
