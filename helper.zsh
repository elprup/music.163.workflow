export PATH=$PATH:/usr/local/bin

source xiami.zsh

# $1: command $2: tab id
execute() {
	cmd=$1
	tab=$2
	if [[ -n "$tab" ]]; then
		chrome-cli execute "$cmd" -t "$tab"
		return 0
	fi
	return 1
}

get_tab() {
	echo `chrome-cli list links | grep $web_url | awk -F'[:\\\[\\\] ]' '{print $2}'`
}

get_title_with_status() {
	tab=`get_tab`
	echo `chrome-cli info -t $tab | grep Title | cut -d ' ' -f 2-`
}

get_title() {
	title=`get_title_with_status`
	echo "${title#▶ }"
}

get_status() {
	title=`get_title_with_status`
	if [[ "$title[1,1]" == "▶" ]]; then
		echo "paused"
	else
		# empty string also falls here
		echo "playing"
	fi
}

get_song_info() {
	tab=`get_tab`
	title=`execute $get_title_cmd $tab`
	artist=`execute $get_artist_cmd $tab`
	if [[ -n "$title" ]]; then
		echo "$title - $artist"
	fi
}

add_fav() {
	tab=`get_tab`
	execute "$open_fav_cmd" "$tab"
	execute "$add_fav_cmd" "$tab"
	get_song_info
}

play() {
	tab=`get_tab`
	execute "$play_cmd" "$tab"
	cmd='(function (){return document.querySelector(".ply").classList.contains("js-pause");})()'
	stat=`execute $cmd $tab`
	if [[ $stat == "0" ]]; then
		get_song_info
	fi
}

prev() {
	tab=`get_tab`
	execute "$prev_cmd" "$tab"
	sleep 1
	get_song_info
}

next() {
	tab=`get_tab`
	execute "$next_cmd" "$tab"
	sleep 1
	get_song_info
}
