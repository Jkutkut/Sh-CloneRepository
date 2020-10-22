# !/usr/bin/sh

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
showSettings(){
  printf "Current settings:\n\tUser: ${YELLOW}$u${NC}\n\tDirectory: ${YELLOW}$fullDirectory${NC}\n\n";
}
getArrow(){
    echo $(/usr/bin/env bash -c "escape_char=\$(printf '\u1b');
    read -rsn1 mode # get 1 character
    if [[ \$mode == \$escape_char ]]; then
        read -rsn2 mode; # read 2 more chars
    fi
    case \$mode in
        '[A') echo UP; exit 0;;
        '[B') echo DN ;;
        '') echo EN;;
        *) >&2 echo 'ERR bad input';;
    esac");
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
            printf "000 $repoL - $index 000"

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
    rm -f temp.txt; # Remove temporal file
    setterm -cursor on; # cursor_blink_on
    stty echo; # Show input text again

    if [ ! "$2" = "noOutput" ]; then # if no "no output" given, give output
      if [ $1 = "fail" ]; then
          echo "\n${RED}~~~~~~~~  ERROR ~~~~~~~~\n$2${NC}";
      fi
    fi
    exit 1;
}

# Constants:
u="Jkutkut"; # Default user name
fullDirectory=~/github/; # Default dir to store the repository


# Code:
trap 'init' WINCH # When window resized, update screen with the new size
trap "endCode fail \"code force-ended\"" 2; # If code forced to end, run endCode first

while true; do
  init "main" "textmode"; # Init zone
  
  
  tput cup $(($titleH+$titleSpace)); # Set cursor at initial position
  
  showSettings;
  ask "Name of the repository?" "[*list, *settings]";
  case $askResponse in
    options|settings|s|o) # Settings
      while true; do
        init "settings" "textmode"; # Init zone
        tput cup $(($titleH+$titleSpace)); # Set cursor at initial position
        showSettings;
        ask "What do you want to change?" "[user, directory, exit]";

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
    list|l) # List
      # Show a list with the avalible repositories of the user ($u) given
      init "list" "optionmode"; # Init zone
      trap 'init' WINCH # When window resized, update screen with the new size

      # Get repo names, store them on a temporal file
      /usr/bin/printf "\n\nGetting al the repos:";
      # Here we have two options:
      #     - Have a file with the repos (one each line). Then edit the line to copy the content to a file named "temp.txt"
      #     - Use the following code to get it:

      ## Get repos as JSON | keep fullname | remove 1º " symbol on each repo | remove 2º " on each repo >> to file named temp.txt
      # curl -u $u:XXXXXXXXXXXXXXXXXXXXXX -s "https://api.github.com/users/$u/repos?type=all&per_page=100" |
      # jq '.[]|.full_name' | cut -d'/' -f 2 | sed 's/.$//' >> temp.txt; # Option 1
      
      # cp repositorios.txt temp.txt; # Option 2

      # At this point, the code should have the temp.txt file created
      /usr/bin/printf '\r\033[0;32m\xE2\x9C\x94\033[0m All repositories obtained:\n';
      repoL=$(wc -l < temp.txt); #Length of the file with the repo names (this is the correct value, last line is an empty line)

      if [ ! -e temp.txt ];then # if file does not exist, error
        echo "\n${RED}~~~~~~~~  ERROR ~~~~~~~~\nNot able to get the repositories. Please check the parameters used are correct and the README.md file.${NC}";
        sleep 1;
        echo "Going back to main section in 5s"
        sleep 5;
        continue; # Go back to the main section
      fi

      start=0;
      selected=0;
      updateScreen "full";
      while true; do
        oldHeight=$height;

        # user key control
        case $(getArrow) in # Get and analize the arrow input
          EN) break;; # If enter pressed, exit
          UP) # If up arrow pressed
              selected=$(($selected-1)); # Selector go up
          ;;
          DN) # If down arrow pressed
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
          if [ $oldHeight -eq $height ]; then # If no change on the height of the screen
            updateScreen "normal";
            continue;
          else # else, update the "full" screen with the new height
            init "list"; # Clear screen, get new height based on the title, titleGap and print it with the fixed position
          fi
        fi
        updateScreen "full";
      done
      # If here, the code has succesfully helped the user to choose the repository
      repoName=$(getLine temp.txt $(( ($start+$selected) % $repoL + 1)) 1);
      break;
    ;;
    *) # If no special command given
      repoName=$askResponse; # Store the name of the Repository.
      break
    ;;
  esac
done

# At this point, everything should be ready to clone:

init "main" "textmode"; # Init zone
tput cup $(($titleH+$titleSpace)); # Set cursor at initial position

echo "
Atempting to clone the reposititory:
\tUser: ${YELLOW}$u${NC}.
\tRepository name: ${YELLOW}$repoName${NC}
\tDirectory to save it: ${YELLOW}$fullDirectory${NC}
"
(cd $fullDirectory ||
endCode "fail" "The directory ${NC}$fullDirectory${RED} was not found") &&
(git clone git@github.com:$u/$repoName.git ||
endCode "fail" "Not possible to clone") &&

echo "--------------------------------------
${LGREEN}
Repository cloned${NC}
"

endCode "correct" "noOutput";