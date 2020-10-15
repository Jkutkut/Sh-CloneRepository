#!/bin/sh

# colors
NC='\033[0m' # No Color
sBG='\e[1;7m';
rBG='\e[1;41m';
bBG='\e[1;44m';
gBG='\e[1;42m';

TITLE='\033[38;5;33m';

# functions
print_option()     { printf "   $1                       "; }
print_selected()   { printf "   ${sBG}$1${NC}                       ";}

# variables
titleH=4;
titleSpace=2;
height=$(($(tput lines)-1-$titleH-$titleSpace-1));


# code
for i in `seq 0 $(tput lines)`; do printf "\n"; done
tput cup 0;
printf "${TITLE} ____  ____  ____   __        __    __  ____  ____ 
(  _ \(  __)(  _ \ /  \  ___ (  )  (  )/ ___)(_  _)
 )   / ) _)  ) __/( () )(___)/ (_/\ )( \___ \  )(  
(__\_)(____)(__)   \__/      \____/(__)(____/ (__)${NC}"

trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
setterm -cursor off; # cursor_blink_off



# OP=(hola que tal);

selected=2;
while true; do
    idx=0;
    for i in `seq 0 $height`; do
        tput cup $(($titleH+$idx+$titleSpace));
        if [ $i -eq $selected ]; then
            print_selected "here"
        else
            print_option "$i";
        fi
        idx=$(($idx+1));
    done

    # user key control
    k=$(./keyInput.sh);
    # echo "k = $k"
    case $k in
        EN) break;;
        UP) 
            selected=$(($selected-1));
            if [ $selected -lt 0 ]; then selected=$(($height)); fi;;
        DN)
            selected=$(($selected+1));
            if [ $selected -ge $(($height+1)) ]; then selected=0; fi;;
    esac
    # break;
done
echo "";
setterm -cursor on; # cursor_blink_on