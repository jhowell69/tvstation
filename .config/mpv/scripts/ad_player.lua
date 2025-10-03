-- CONFIG
local ad_folder = "/home/tvbox/Videos/ads"
local played_ads_file = "/tmp/played_ads"
local ad_lock_file = "/tmp/ad_playing.lock"
local ad_script_path = "/tmp/ad_exit.lua"

local enable_weatherandtimebumper = true
local online_or_not_file = io.open("/tmp/amionline.bool", "r")

if online_or_not_file and enable_weatherandtimebumper then
        local online_or_not = online_or_not_file:read("*a")
        online_or_not_file:close()
end


-- STATE
local triggered_chapters = {}
local last_chapter = -1
local timer = nil

-- Read played ads from file
function get_played_ads()
    local ads = {}
    local f = io.open(played_ads_file, "r")
    if f then
        for line in f:lines() do
            if line ~= "" then
                ads[line] = true
            end
        end
        f:close()
    end
    return ads
end

-- Save played ad to file
function record_played_ad(ad_path)
    local f = io.open(played_ads_file, "a")
    if f then
        f:write(ad_path .. "\n")
        f:close()
    end
end

-- Get a unique ad
function get_unique_ad()
    local handle = io.popen('find "' .. ad_folder .. '" -type f \\( -iname "*.mp4" -o -iname "*.webm" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.avi" \\)')
    if not handle then return nil end

    local all_ads = {}
    for line in handle:lines() do
        table.insert(all_ads, line)
    end
    handle:close()

    local played = get_played_ads()
    local unplayed = {}

    for _, ad in ipairs(all_ads) do
        if not played[ad] then
            table.insert(unplayed, ad)
        end
    end

    if #unplayed == 0 then
        os.remove(played_ads_file)
        if #all_ads == 0 then return nil end
        return all_ads[math.random(1, #all_ads)]
    else
        return unplayed[math.random(1, #unplayed)]
    end
end

-- Get duration of a video file using ffprobe
function get_video_duration(path)
    local probe = io.popen('ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "' .. path .. '"')
    local duration_str = probe:read("*a")
    probe:close()
    return tonumber(duration_str)
end

-- Create lock file and ad exit script
function prepare_ad_environment()
    local lock = io.open(ad_lock_file, "w")
    if lock then lock:close() end

    local ad_script = [[
        mp.register_event("shutdown", function()
            os.remove("]] .. ad_lock_file .. [[")
        end)
    ]]
    local f = io.open(ad_script_path, "w")
    if f then
        f:write(ad_script)
        f:close()
    end
end

-- launch weather channel during ad break
if online_or_not == "true" then os.execute("~/weatherchannel.sh") end

-- Recursive ad playback
function play_ads_sequentially(ads, index)
    if index > #ads then
        mp.set_property("pause", "no")
        -- Reapply logo overlay after ads finished
        os.execute("/home/tvbox/start_overlay.sh")
        return
    end

    local lock = io.open(ad_lock_file, "w")
    if lock then lock:close() end

    mp.commandv("run", "mpv", ads[index], "--geometry=100%:100%", "--no-terminal", "--quiet", "--fs", "--script=" .. ad_script_path)

    timer = mp.add_periodic_timer(1, function()
        local check = io.open(ad_lock_file, "r")
        if not check then
            timer:kill()
            play_ads_sequentially(ads, index + 1)
        else
            check:close()
        end
    end)
end

-- Trigger on any chapter
mp.observe_property("chapter", "number", function(name, value)
    if value and value ~= last_chapter then
        last_chapter = value
        os.execute("/home/tvbox/kill_overlay.sh")
        if not triggered_chapters[value] then
            triggered_chapters[value] = true
            mp.set_property("pause", "yes")

            -- Set ad duration rules based on chapter
            local ads = {}
            local total_duration = 0
            local min_ads = 1
            local min_seconds = 0
            local max_seconds = 60

            if value == 1 or value == 2 then
                min_ads = 2
                min_seconds = 180
                max_seconds = math.huge
            end

            while (#ads < min_ads or total_duration < min_seconds) and total_duration < max_seconds do
                local ad = get_unique_ad()
                if not ad then
                    os.remove(played_ads_file)
                    mp.set_property("pause", "no")
                    return
                end

                local duration = get_video_duration(ad)
                if duration then
                    if total_duration + duration > max_seconds then break end
                    record_played_ad(ad)
                    table.insert(ads, ad)
                    total_duration = total_duration + duration
                end
            end

            if #ads == 0 then
             -- mp.osd_message("No ads selected", 3)
                mp.set_property("pause", "no")
                return
            end

            prepare_ad_environment()
            play_ads_sequentially(ads, 1)
        end
    end
end)
