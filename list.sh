#!/bin/sh

# functions
print_option()     { printf "   $1 "; }
print_selected()   { printf "  \e[1;7m$1\e[0m"; }

# variables
height=$(($(tput lines)-1));


# code
for i in `seq 0 $height`; do printf "\n"; done

trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
# setterm -cursor off; # cursor_blink_off

selected=2;
while true; do
    idx=0;
    for i in `seq 0 $height`; do
        tput cup $idx;
        if [ $i -eq $selected ]; then
            # print_selected "here";
            print_selected "hola"
        else
            print_option "$i";
        fi
        idx=$(($idx+1));
    done
done
# setterm -cursor on; # cursor_blink_on