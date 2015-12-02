export PATH=$PATH:/usr/local/bin

# defaults
play_cmd=''
prev_cmd=''
next_cmd=''
get_title_cmd=''
get_artist_cmd=''
open_fav_cmd=''
add_fav_cmd=''
get_state_cmd='(function (){return document.readyState;})()'
web_url=''
tab=''

# override defaults
source 163.zsh

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

get_state() {
	state=`execute $get_state_cmd $tab`
        echo $state
}

set_tab() {
	tab=`chrome-cli list links | grep $web_url | python -c "import re,sys;sys.stdout.write(re.findall(r'\[([0-9:]+)\]',sys.stdin.read())[0].split(':')[-1])"`
}

wait_tab() {
        while [[ ! -n "$tab" ]] || [[ `get_state` != "complete" ]]; do
		set_tab
		if [[ ! -n "$tab" ]]; then
			>&2 echo 'tab not found, create new'
			chrome-cli open http://$web_url/ > /dev/null
			sleep 1
		else
			>&2 echo 'wait for tab ready'
			sleep 1
		fi
	done
}

get_title_with_status() {
	wait_tab
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
	wait_tab
	title=`execute $get_title_cmd $tab`
	artist=`execute $get_artist_cmd $tab`
	if [[ -n "$title" ]]; then
		echo "$title - $artist"
	fi
}

add_fav() {
	wait_tab
	execute "$open_fav_cmd" "$tab"
	execute "$add_fav_cmd" "$tab"
	get_song_info
}

play() {
	wait_tab
	execute "$play_cmd" "$tab"
	cmd='(function (){return document.querySelector(".ply").classList.contains("js-pause");})()'
	stat=`execute $cmd $tab`
	if [[ $stat == "0" ]]; then
		get_song_info
	fi
}

prev() {
	wait_tab
	execute "$prev_cmd" "$tab"
	sleep 1
	get_song_info
}

next() {
	wait_tab
	execute "$next_cmd" "$tab"
	sleep 1
	get_song_info
}
