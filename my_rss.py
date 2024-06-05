import requests
import json
import datetime
import xml.etree.ElementTree as ET

# Function to get the current date and time
def get_current_datetime():
    return datetime.datetime.now().strftime('%m%d.%H:%M')

# Function to update tor_history.json
def update_tor_history(pubdate, title, torrent, guid, tag, tor_history_file='/config/www/webui/tor_history.json'):
    try:
        with open(tor_history_file, 'r') as file:
            tor_history = json.load(file)
    except (FileNotFoundError, json.JSONDecodeError):
        tor_history = []

    # Check if the guid already exists in tor_history.json
    if not any(entry['guid'] == guid for entry in tor_history):
        # Add the new entry
        new_entry = {
            'pubdate': pubdate,
            'title': title,
            'torrent': torrent,
            'guid': guid,
            'tag': tag
        }
        tor_history.append(new_entry)
        with open(tor_history_file, 'w') as file:
            json.dump(tor_history, file, indent=4)

# Fetch data from URLs
rss_offkab_xml = requests.get('https://sukebei.nyaa.si/?page=rss&q=FHD+-FHDC+-FC2&c=0_0&f=0&u=offkab').text
reject_json = requests.get('https://raw.githubusercontent.com/chanh0/j_script/master/reject.json').json()
unraid_json = requests.get('https://raw.githubusercontent.com/chanh0/j_script/master/unraid.json').json()

# Extract BAM and ACC values
BAM = [item['BAM'] for item in reject_json]
ACC = [item['ACC'] for item in unraid_json]

# Initialize RSS output
rss_output = {
    'ARIA2JP': f"""<rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
<comments>This is aria2jp accept torrent</comments>
<comments>Last Update : {get_current_datetime()}</comments>
<channel>""",
    'UNRAID': ''
}
rss_output['UNRAID'] = rss_output['ARIA2JP']

# Parse the XML
root = ET.fromstring(rss_offkab_xml)
items = root.findall('.//item')

# Process each item in the XML
for item in items[:75]:
    title = item.find('title').text[:50]
    link = item.find('link').text
    guid = item.find('guid').text
    infohash = item.find('{https://sukebei.nyaa.si/xmlns/nyaa}infoHash').text
    pubdate = item.find('pubDate').text
    size = item.find('{https://sukebei.nyaa.si/xmlns/nyaa}size').text

    matched = False
    tag = 'ARIA2JP'
    for acc in ACC:
        if acc in title:
            matched = True
            tag = 'UNRAID'
            break

    bamed = False
    if not matched:
        for bam in BAM:
            if bam in title:
                bamed = True
                break

    if not bamed:
        sortable_pubdate = datetime.datetime.strptime(pubdate, '%a, %d %b %Y %H:%M:%S %z').strftime('%Y-%m-%dT%H:%M:%S%z')
        update_tor_history(sortable_pubdate, title, link, guid, tag)

        rss_output[tag] += f"""
<item>
  <title><![CDATA[{title}]]></title>
  <link>{link}</link>
  <guid>{guid}</guid>
  <infohash>{infohash}</infohash>
  <pubDate>{pubdate}</pubDate>
  <size>{size}</size>
</item>"""

# Close RSS structures
rss_output['ARIA2JP'] += "\n</channel>\n</rss>"
rss_output['UNRAID'] += "\n</channel>\n</rss>"

# Write output to files
with open('/config/www/webui/jprss.xml', 'w') as f:
    f.write(rss_output['ARIA2JP'])

with open('/config/www/webui/unraidrss.xml', 'w') as f:
    f.write(rss_output['UNRAID'])

timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
print(f"RSS feeds generated and written to files successfully at {timestamp}.")
