#! /bin/bash

# The first param will be the ID of the YouTube Channel (For eg, if the ID is @CigarettesAfterSex, then input CigarettesAfterSex, case insensitive)

releases="$(curl -s https://www.youtube.com/@$1/releases | sed s/}/\\n/g |  sed s/playlistRenderer/playlistRenderer\\n/ | grep playlistId | grep simpleText)"

# Saving playlistID, Album Name and total count of Albums
id=$(echo "$releases" | cut -d \" -f5)
name=$(echo "$releases" | cut -d \" -f11)
count=$(echo "$releases" | wc -l)

# URL template for input into yt-dlp
template="https://www.youtube.com/playlist?list="

# Creating Artist's directory
if [ ! -d "$1" ]; then # If directory does not exists then create it
	mkdir "$1"
fi

cd "$1"

for (( i = 1 ; i <= $count ; i++ )); do
	dir=$(echo "$name" | sed -n "$i"p)
	curr_id=$(echo "$id" | sed -n "$i"p) # | sed s/&/\'&\'/g) # Added in case playlistID contains &, needs to be replaced by \'&\' for yt-dlp without forward slash
	if [ ! -d "$dir" ]; then # If directory does not exist then create it
		mkdir "$dir"
	fi
	cd "$dir"
	yt-dlp -x --progress --no-warnings -q --audio-quality 0 --embed-thumbnail "$template$curr_id" && cd ..
done
