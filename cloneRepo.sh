#!/bin/sh

#colors:
NC='\033[0m' # No Color
sBG='\e[1;7m';
rBG='\e[1;41m';
bBG='\e[1;44m';
gBG='\e[1;42m';
RED='\033[0;31m';
GREEN='\033[0;32m';
LRED='\033[1;31m';
LGREEN='\033[1;32m';
YELLOW='\033[1;33m';
LBLUE='\033[1;34m';
TITLE='\033[38;5;33m';


# FUNCTIONS
askResponse=""; #When executing the function ask(), the response will be stored here
ask(){ # to do the read in terminal, save the response in askResponse
  text=$1;
  textEnd=$2;
  read -p "$(echo ${LBLUE}"$text"${NC} $textEnd)->" askResponse;
}
error(){ # function to generate the error messages. If executed, ends the script.
  err=$1;
  echo "${RED}~~~~~~~~  ERROR ~~~~~~~~
    $1${NC}";
  exit 1
}

init(){
    # variables
    titleH=4;
    titleSpace=2;
    height=$(($(tput lines)-1-$titleH-$titleSpace-1));

    # code
    for i in `seq 0 $(tput lines)`; do printf "\n"; done # Clear the terminal
    tput cup 0; # Set cursor on the top of the screen

    case $1 in
        main)
            printf "${TITLE}  ___  __     __   __ _  ____  ____  ____  ____   __  
 / __)(  )   /  \ (  ( \(  __)(  _ \(  __)(  _ \ /  \ 
( (__ / (_/\( () )/    / ) _)  )   / ) _)  ) __/( () )
 \___)\____/ \__/ \_)__)(____)(__\_)(____)(__)   \__/${NC}";
        ;;
        list)
            printf "${TITLE} ____  ____  ____   __        __    __  ____  ____ 
(  _ \(  __)(  _ \ /  \  ___ (  )  (  )/ ___)(_  _)
 )   / ) _)  ) __/( () )(___)/ (_/\ )( \___ \  )(  
(__\_)(____)(__)   \__/      \____/(__)(____/ (__)${NC}";
        ;;
        settings)
          printf "${TITLE} ___  ____  ____  ____  ____  _  _  ___  ___ 
/ __)( ___)(_  _)(_  _)(_  _)( \( )/ __)/ __)
\__ \ )__)   )(    )(   _)(_  )  (( (_-.\\__ \\
(___/(____) (__)  (__) (____)(_)\_)\___/(___/
${NC}";
        ;;
    esac

    if [ ! $2 = "textmode" ]; then # If no textmode => option mode
      setterm -cursor off; # cursor_blink_off
      stty -echo; # hide text typed
    else
      setterm -cursor on; # cursor_blink_off
      stty echo; # hide text typed
    fi

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

    if [ ! "$2" = "noOutput" ]; then # if no "no output" given, give output
      if [ $1 = "fail" ]; then
          echo "\n${RED}~~~~~~~~  ERROR ~~~~~~~~
      $2${NC}";
      else
          repo=$(getLine temp.txt $(( ($start+$selected) % $repoL + 1)) 1);
          echo "\nSelected option: $repo";
      fi
    fi
    exit 1;
}

# Variables:
u="jkutkut" # Default user name
fullDirectory=~/github/$repoName # Default dir to store the repository

# Code:


trap 'init' WINCH # When window resized, update screen with the new size
trap "endCode fail \"code force-ended\"" 2; # If code forced to end, run endCode first

while true; do
  init "main" "textmode"; # Init zone
  
  start=0; selected=2;
  tput cup $(($titleH+$titleSpace)); # Set cursor at initial position
  
  ask "Name of the repository?" "[*list, *settings]";
  case $askResponse in
    list|l)
    ;;
    options|settings|s|o) # Settings
      while true; do
        init "settings" "textmode"; # Init zone
        echo "\nCurrent settings:\n\tUser: ${YELLOW}" $u "${NC}\n\tDirectory: ${YELLOW}" $fullDirectory "${NC}\n"; 
        ask "What do you want to change?" "[user, directory, exit]";
      done
    ;;
    *) # If no special command given
      repoName=$askResponse; # Store the name of the Repository.
      break
    ;;
  esac
done

# At this point, everything should be ready to clone:
echo "
Atempting to clone the reposititory:
\tUser: ${YELLOW}$u${NC}.
\tRepository name: ${YELLOW}$repoName${NC}
\tDirectory to save it: ${YELLOW}$fullDirectory${NC}
"

# (git clone git@github.com:$u/$repoName.git ||
# error "not possible to clone") &&

echo "--------------------------------------
${LGREEN}
Repository cloned${NC}
"

endCode "correct" "noOutput";