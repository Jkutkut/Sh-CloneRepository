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

trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
setterm -cursor off; # cursor_blink_off
stty -echo;

# Get repo names, store them on a temporal file
/usr/bin/printf "\n\nGetting al the repos:";
# curl -u  -s "https://api.github.com/users/jkutkut/repos?type=all&per_page=100" |
# jq '.[]|.full_name' | cut -d'/' -f 2 | sed 's/.$//' >> temp.txt;
/usr/bin/printf '\r\033[0;32m\xE2\x9C\x94\033[0m All repositories obtained:\n';

start=0;
selected=2;
while true; do
    idx=0;
    for i in `seq 0 $height`; do
        tput cup $(($titleH+$idx+$titleSpace));
        index=$(($i+1));
        text=$(getLine temp.txt $index 1);


        if [ $i -eq $selected ]; then
            # printf "${sBG}";
            setMessage $text 3 $sBG;
            printf "${NC}";
        else
            setMessage $text 3;
        fi
        idx=$(($idx+1));
    done

    # user key control
    k=$(./keyInput.sh);
    case $k in
        EN) break;;
        UP) 
            selected=$(($selected-1));
            if [ $selected -lt 0 ]; then selected=$(($height)); fi;;
        DN)
            selected=$(($selected+1));
            if [ $selected -ge $(($height+1)) ]; then selected=0; fi;;
    esac
done
echo "";
setterm -cursor on; # cursor_blink_on
stty echo;
# rm temp.txt; # Remove temporal file
