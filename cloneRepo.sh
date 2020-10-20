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


echo "${TITLE}  ___  __     __   __ _  ____  ____  ____  ____   __  
 / __)(  )   /  \ (  ( \(  __)(  _ \(  __)(  _ \ /  \ 
( (__ / (_/\( () )/    / ) _)  )   / ) _)  ) __/( () )
 \___)\____/ \__/ \_)__)(____)(__\_)(____)(__)   \__/${NC}"


u="jkutkut"
fullDirectory=~/github/$repoName

ask "Name of the repository?" "[*list, *user]";

case $askResponse in
  list|l)
    echo "list";
  ;;
  options|settings|s|o)
    while true; do
      echo "\nCurrent settings:\n\tUser: " $u "\n\tDirectory: " $fullDirectory "\n"; 
      ask "What do you want to change?" "[user, directory, exit]"
      case $askResponse in
        user|u)
          ask "Name of the user?" "";
          u=$askResponse;
        ;;
        directory|dir|d)
          ask "Enter the custom directory" "";
          fullDirectory=$askResponse;
        ;;
        exit|e)
          break;
        ;;
      esac
    done
  ;;
  *) # If no special command given
    repoName=$askResponse; # Store the name of the Repository.
  ;;
esac

dialog --menu "Choose one:" 10 30 3 \
    1 Red \
    2 Green \
    3 Blue

echo $askResponse
echo $fullDirectory
ls $fullDirectory
# echo "
# Atempting to clone the reposititory on ${YELLOW}$fullDirectory${NC}
# and connect it to the user ${YELLOW}$u${NC}.
# "

# (git clone git@github.com:Jkutkut/$repoName.git ||
# error "not possible to clone") &&

# echo "--------------------------------------
# ${LGREEN}
# Repository cloned${NC}
# "