#! /bin/bash

help() {
printf "Usage: ./dl.sh [options] ChannelID \n\n"
printf "Options:\n"
printf "  -d, --directory      Create Directories for All Albums"
exit 0
}

f=0
while getopts ":hd:" flag; do
	case $1 in
		-d | --directory) f=1 && shift 1;;
		-h | --help) help | less && exit 0;;
		\?) echo Invalid Option - "$1" && exit 0;;
	esac
done

# The first param will be the ID of the YouTube Channel (For eg, if the ID is @CigarettesAfterSex, then input CigarettesAfterSex, case insensitive)

releases="$(curl -s https://www.youtube.com/@$1/releases | sed s/}/\\n/g |  sed s/playlistRenderer/playlistRenderer\\n/)"


# Saving playlistID, Album Name and total count of Albums
id=$(echo "$releases" | grep playlistId | grep simpleText | cut -d \" -f5)
name=$(echo "$releases" | grep playlistId | grep simpleText| cut -d \" -f11)
artist_name=$(echo  "$releases" | grep urlCanonical | cut -d \" -f12 | sed 's/ /\ /g')
count=$(echo "$releases" | wc -l)

# URL template for input into yt-dlp
template="https://www.youtube.com/playlist?list="

# Creating Artist's directory
if [ ! -d "$artist_name" ]; then # If directory does not exists then create it
	mkdir "$artist_name"
fi

cd "$artist_name"

for (( i = 1 ; i <= $count ; i++ )); do
	dir=$(echo "$name" | sed -n "$i"p)
	curr_id=$(echo "$id" | sed -n "$i"p) # | sed s/&/\'&\'/g) # Added in case playlistID contains &, needs to be replaced by \'&\' for yt-dlp without forward slash
	if [ "$f" = 1 ]; then
		if [ ! -d "$dir" ]; then # If directory does not exist then create it
			mkdir "$dir"
		fi
		cd "$dir"
	fi
	yt-dlp -x --progress --no-warnings -q --audio-quality m4a --parse-metadata "$dir:%(album)s"  --embed-metadata --embed-thumbnail "$template$curr_id"
	for file in *.m4a; do
		renamed_file=$(echo "$file" | sed 's/ \[[^]]*\]//g') # | sed 's/ /\\ /g')
		mv "$file" "$renamed_file"
	done
	if [ "$f" = 1 ]; then
		cd ..
	fi
done
