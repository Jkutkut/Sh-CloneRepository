#!/bin/sh

# colors
NC='\033[0m' # No Color
sBG='\e[1;7m';
rBG='\e[1;41m';
bBG='\e[1;44m';
gBG='\e[1;42m';

TITLE='\033[38;5;33m';

# functions
setMessage(){
    if [ $# -eq 1 ]; then # If no offset given, supose 0
        offs=0;
    else # If given, use it
        offs=$2;
    fi
    l=$(tput cols); # cols of the terminal
    gap=$(($l-${#1}-$offs)); # characters I can fit between the end of the message and the end of the terminal
    
    printf %${offs}s; # Print offset
    printf $3$1${NC}; # print message with the color given
    printf %${gap}s; # print the end of the line with blank characters
}
getLine(){
    start=$2;
    get=$3;
    echo $(tail -n +$start $1 | head -n $get);
}

# variables
titleH=4;
titleSpace=2;
height=$(($(tput lines)-1-$titleH-$titleSpace-1));


# code
for i in `seq 0 $(tput lines)`; do printf "\n"; done # Clear the terminal
tput cup 0; # Set cursor on the top of the screen
printf "${TITLE} ____  ____  ____   __        __    __  ____  ____ 
(  _ \(  __)(  _ \ /  \  ___ (  )  (  )/ ___)(_  _)
 )   / ) _)  ) __/( () )(___)/ (_/\ )( \___ \  )(  
(__\_)(____)(__)   \__/      \____/(__)(____/ (__)${NC}"

setterm -cursor off; # cursor_blink_off
stty -echo;

# Get repo names, store them on a temporal file
/usr/bin/printf "\n\nGetting al the repos:";
# curl -u  -s "https://api.github.com/users/jkutkut/repos?type=all&per_page=100" |
# jq '.[]|.full_name' | cut -d'/' -f 2 | sed 's/.$//' >> temp.txt;
/usr/bin/printf '\r\033[0;32m\xE2\x9C\x94\033[0m All repositories obtained:\n';

repoL=$(wc -l < temp.txt); #Length of the file with the repo names

# trap "echo \"exit\"; status=fail; setterm -cursor on; stty echo; rm temp.txt; exit;" 2;
trap "echo \"exit\"; status=fail; setterm -cursor on; stty echo; exit;" 2;

start=0;
selected=2;
while true; do
    idx=0;
    for i in `seq 0 $height`; do
        tput cup $(($titleH+$idx+$titleSpace));
        index=$(( ($start+$i) % $repoL + 1));#Get the lenght of the element
        text=$(getLine temp.txt $index 1);


        if [ $i -eq $selected ]; then
            setMessage $text 3 $sBG;
        else
            setMessage $text 3;
        fi
        idx=$(($idx+1));
    done

    # user key control
    k=$(./keyInput.sh); # Get and analize the input
    case $k in
        EN) break;; # If enter pressed, exit
        UP) # If up arrow pressed
            selected=$(($selected-1)); # Selector go up
            if [ $selected -lt 0 ]; then # If selector out of screen
                selected=0; # Selector now on top
                start=$(($start-1)); # Move all repos down
                if [ $start -lt 0 ]; then # If out of index
                    start=$repoL; # Set index to the last one
                fi
            fi
        ;;
        DN)
            selected=$(($selected+1));
            if [ $selected -ge $(($height+1)) ]; then
                selected=$height;
                start=$(($start+1)); # Move all repos up
                if [ $start -ge $(($repoL+1)) ]; then
                    start=0;
                fi
            fi;;
    esac
done

repo=$(getLine temp.txt $(( ($start+$selected) % $repoL + 1)) 1);
# rm temp.txt; # Remove temporal file

setterm -cursor on; # cursor_blink_on
stty echo; # Show input text again

echo "\nSelected option: $repo";