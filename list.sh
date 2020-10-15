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
    printf $4$1${NC}; # print message with the color given
    printf %${gap}s; # print the end of the line with blank characters
}

# variables
titleH=4;
titleSpace=2;
height=$(($(tput lines)-1-$titleH-$titleSpace-1));


# code
for i in `seq 0 $(tput lines)`; do printf "\n"; done # Clear the terminal
tput cup 0;
printf "${TITLE} ____  ____  ____   __        __    __  ____  ____ 
(  _ \(  __)(  _ \ /  \  ___ (  )  (  )/ ___)(_  _)
 )   / ) _)  ) __/( () )(___)/ (_/\ )( \___ \  )(  
(__\_)(____)(__)   \__/      \____/(__)(____/ (__)${NC}"

trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
setterm -cursor off; # cursor_blink_off

# Get repo names, store them on a temporal file
curl -u jkutkut:9f3097b9f4e189766e98c92775743249aa6d565f -s "https://api.github.com/users/jkutkut/repos?type=all&per_page=100" |
jq '.[]|.full_name' | cut -d'/' -f 2 | sed 's/.$//' >> temp.txt;
REPOS=$(tail -n +$start temp.txt | head -n $get);



# OP=(hola que tal);

selected=2;
while true; do
    idx=0;
    for i in `seq 0 $height`; do
        tput cup $(($titleH+$idx+$titleSpace));
        if [ $i -eq $selected ]; then
            printf "${sBG}";
            setMessage "here" 3 $sBG;
            printf "${NC}";
        else
            setMessage $i 3;
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
rm temp.txt; # Remove temporal file