#!/bin/sh

# colors
NC='\033[0m' # No Color
sBG='\e[1;7m';
rBG='\e[1;41m';
bBG='\e[1;44m';
gBG='\e[1;42m';

TITLE='\033[38;5;33m';

# functions
init(){
    # variables
    titleH=4;
    titleSpace=2;
    height=$(($(tput lines)-1-$titleH-$titleSpace-1));

    # code
    for i in `seq 0 $(tput lines)`; do printf "\n"; done # Clear the terminal
    tput cup 0; # Set cursor on the top of the screen
    printf "${TITLE}$1${NC}"

    setterm -cursor off; # cursor_blink_off
    stty -echo;

}

updateScreen(){
    idx=0;
    if [ "full" = $1 ]; then
        for i in $(seq 0 $height); do
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
    else
        
        for i in $(seq -1 1); do
            line=$(($titleH+$titleSpace+$selected+$i));
            if [ $(($selected+$i)) -gt $height ] || [ $(($selected+$i)) -eq -1 ]; then 
                continue;
            fi
            tput cup $line;
            index=$(( ($start+$selected+$i) % $repoL + 1));#Get the lenght of the element
            text=$(getLine temp.txt $index 1);
            
            if [ $i -eq 0 ]; then
                setMessage $text 3 $sBG;
            else
                setMessage $text 3;
            fi
            idx=$(($idx+1));
        done
    fi
}

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

endCode(){
    # rm temp.txt; # Remove temporal file
    setterm -cursor on; # cursor_blink_on
    stty echo; # Show input text again

    if [ $1 = "fail" ]; then
        echo "${RED}~~~~~~~~  ERROR ~~~~~~~~
    $2${NC}";
    else
        repo=$(getLine temp.txt $(( ($start+$selected) % $repoL + 1)) 1);
        echo "\nSelected option: $repo";
    fi
    echo $1;
    exit 1;
}



init " ____  ____  ____   __        __    __  ____  ____ 
(  _ \(  __)(  _ \ /  \  ___ (  )  (  )/ ___)(_  _)
 )   / ) _)  ) __/( () )(___)/ (_/\ )( \___ \  )(  
(__\_)(____)(__)   \__/      \____/(__)(____/ (__)"; # Init zone
trap 'init' WINCH # When window resized, update screen with the new size
trap "endCode \"fail\"" 2; # If code forced to end, run endCode first

# Get repo names, store them on a temporal file
/usr/bin/printf "\n\nGetting al the repos:";
# curl -u  -s "https://api.github.com/users/jkutkut/repos?type=all&per_page=100" |
# jq '.[]|.full_name' | cut -d'/' -f 2 | sed 's/.$//' >> temp.txt;
/usr/bin/printf '\r\033[0;32m\xE2\x9C\x94\033[0m All repositories obtained:\n';
repoL=$(($(wc -l < temp.txt) + 1)); #Length of the file with the repo names



start=0;
selected=2;

updateScreen "full";
while true; do

    # user key control
    k=$(./keyInput.sh); # Get and analize the input
    case $k in
        EN) break;; # If enter pressed, exit
        UP) # If up arrow pressed
            selected=$(($selected-1)); # Selector go up
        ;;
        DN)
            selected=$(($selected+1));
        ;;
    esac

    if [ $selected -eq -1 ]; then # If selector out of screen
        selected=0; # Selector now on top
        start=$(($start-1)); # Move all repos down
        if [ $start -eq -1 ]; then # If out of index
            start=$(($repoL - 1)); # Set index to the last one
        fi

    elif [ $selected -ge $(($height+1)) ]; then
        selected=$height;
        start=$(($start+1)); # Move all repos up
        if [ $start -ge $(($repoL+1)) ]; then
            start=0;
        fi
    else
        updateScreen "normal";
        continue;
    fi
    updateScreen "full";
done

endCode "correct";