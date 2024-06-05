#/bin/bash
# version 0.31
[ ! -f /usr/bin/xmlstarlet ] && apk add xmlstarlet
DATE_TIME() {
    #date +"%m/%d %H:%M:%S"
    TODAY=$(date '+%m%d.%H:%M')
}
DATE_TIME

# Function to update tor_history.json
TOR_HIS_JSON() {
    local pubdate=$1
    local title=$2
    local torrent=$3
    local guid=$4
    local tag=$5
    local tor_history_file="/config/www/webui/tor_history.json"

    # Check if tor_history.json exists, if not or it's empty, create an empty array
    if [ ! -f "$tor_history_file" ] || [ ! -s "$tor_history_file" ]; then
        [ -f "$tor_history_file" ] && rm "$tor_history_file"
        echo "[]" > "$tor_history_file"
    fi

    # Check if the guid already exists in tor_history.json
    if ! jq -e ".[] | select(.guid == \"$guid\")" "$tor_history_file" > /dev/null; then
        # Add the new entry
        new_entry=$(jq -n \
            --arg pubdate "$pubdate" \
            --arg title "$title" \
            --arg torrent "$torrent" \
            --arg guid "$guid" \
            --arg tag "$tag" \
            '{pubdate: $pubdate, title: $title, torrent: $torrent, guid: $guid, tag: $tag}')
        jq ". += [$new_entry]" "$tor_history_file" > tmpjp.$$.json && mv tmpjp.$$.json "$tor_history_file"
    fi
}

rss_offkab_xml=$(curl -s -X GET   -H "Content-type: application/json"   -H "Accept: application/json"   "https://sukebei.nyaa.si/?page=rss&q=FHD+-FHDC+-FC2&c=0_0&f=0&u=offkab" ) 2>/dev/null
staging=$(xmlstarlet sel -t -m "//item" -v "substring(title, 1, 50)" -o " | " -v "link" -o " | " -v "guid" -o " | " -v "nyaa:infoHash" -o " | " -v "pubDate" -o " | " -v "nyaa:size" -n  <<< "$rss_offkab_xml" | head -n 75)

# Set the string to match # Read reject.json and extract BAM values
reject_json=$(curl -s  -connection-timeout 0.5 --max-time 0.8 https://raw.githubusercontent.com/chanh0/j_script/master/reject.json| jq . )
unraid_json=$(curl -s  -connection-timeout 0.5 --max-time 0.8 https://raw.githubusercontent.com/chanh0/j_script/master/unraid.json| jq . )
mapfile -t BAM < <(jq -r '.[].BAM' <<< "$reject_json")
mapfile -t ACC < <(jq -r '.[].ACC' <<< "$unraid_json")
#echo ${ACC[@]}
#echo ${BAM[@]}

# Initialize rss_output and unrss_output
declare -A rss_output

rss_output[ARIA2JP]=$(cat <<EOF
<rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
<comments>This is aria2jp accept torrent</comments>
<comments>Last Update : $TODAY</comments>
<channel>
EOF
)

rss_output[UNRAID]="${rss_output[ARIA2JP]}"

# Iterate over staging list
while IFS= read -r line; do
    # Extract title from each line
    title=$(echo "$line" | cut -d "|" -f 1)

    # Check if title matches any BAM value
    matched=false
    tag="ARIA2JP"
    for c in "${ACC[@]}"; do
        if [[ $title == *"$c"* ]]; then
            :
            #echo "UNRAID $line"
            matched=true
            tag="UNRAID"
            break  #remark 22
        fi
    done
    #remark 22

    bamed=false
    if ! $matched; then
        for b in "${BAM[@]}"; do
                if [[ $title == *"$b"* ]]; then
                    :
                    #echo "BAM $line"
                    bamed=true
                    break  #remaek 23
                fi
        done
    #remake 23
    fi

    # If no bam
    if ! $bamed; then
                :
                #echo "ARIA2JP $line"
                # Extract the title and torrent link from the line
                title=$(echo "$line" | awk -F '|' '{print $1}' | sed 's/^+++ \[FHD\] //')
                torrent=$(echo "$line" | awk -F '|' '{print $2}' | xargs)
                guid=$(echo "$line" | awk -F '|' '{print $3}' | xargs)
                infohash=$(echo "$line" | awk -F '|' '{print $4}' | xargs)
                pubdate=$(echo "$line" | awk -F '|' '{print $5}' | xargs)
                size=$(echo "$line" | awk -F '|' '{print $6}' | xargs)
                #echo "$title and  $torrent"

                # Convert pubDate to sortable format
                sortable_pubdate=$(date -d "$pubdate" '+%Y-%m-%dT%H:%M:%S%z')

                # Call the function to update tor_history.json as processed
                TOR_HIS_JSON "$sortable_pubdate" "$title" "$torrent" "$guid" "$tag"


                # Create RSS format output
                rss_output[$tag]+=$(cat <<EOF
<item>
  <title><![CDATA[$title]]></title>
  <link>$torrent</link>
  <guid>$guid</guid>
  <infohash>$infohash</infohash>
  <pubDate>$pubdate</pubDate>
  <size>$size</size>
</item>
EOF
)
    fi
done <<< "$staging" #while end

# Close RSS structures
rss_output[ARIA2JP]+="</channel>\n</rss>"
rss_output[UNRAID]+="</channel>\n</rss>"

# Output to console
#echo -e "${rss_output[ARIA2JP]}"
jprssdest="/config/www/webui/jprss.xml"
echo -e "${rss_output[ARIA2JP]}" > "$jprssdest"

unrssdest="/config/www/webui/unraidrss.xml"
echo -e "${rss_output[UNRAID]}" > "$unrssdest"

ls -l /config/www/webui/*.xml