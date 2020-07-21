#!/bin/sh

#colors:
  NC='\033[0m' # No Color
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  LRED='\033[1;31m'
  LGREEN='\033[1;32m'
  YELLOW='\033[1;33m'
  LBLUE='\033[1;34m'
  TITLE='\033[38;5;33m'

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
echo "${TITLE}   _____ _                  _____                      _ _                   
  / ____| |                |  __ \                    (_) |                  
 | |    | | ___  _ __   ___| |__) |___ _ __   ___  ___ _| |_ ___  _ __ _   _ 
 | |    | |/ _ \| '_ \ / _ \  _  // _ \ '_ \ / _ \/ __| | __/ _ \| '__| | | |
 | |____| | (_) | | | |  __/ | \ \  __/ |_) | (_) \__ \ | || (_) | |  | |_| |
  \_____|_|\___/|_| |_|\___|_|  \_\___| .__/ \___/|___/_|\__\___/|_|   \__, |
                                      | |                               __/ |
                                      |_|                              |___/ ${NC}"

#Select the name of the user on Github
# --------- OPTION 1 ---------
# ask "Name of the user?" "";
# u=$askResponse;

# --------- OPTION 2 ---------
u="jkutkut"

ask "Name of the repository?" "";
repoName=$askResponse; # Store the name of the Repository.

#Select the name of the user on Github
# --------- OPTION 1 ---------
# ask "Do you want to store the repository here?" "[yes/y], [no,n]"
# case $askResponse in
#   yes|y|Yes|Y)
#       directory="github";
#   ;;
#   no|n|No|N)
#       ask "Enter the custom directory" "";
#       directory=$askResponse;
#   ;;
#   *)
#       echo "Not found";
#   ;;
# esac
# fullDirectory=~/$directory/$repoName

# --------- OPTION 2 ---------
fullDirectory=~/github/$repoName


echo "
Atempting to clone the reposititory on ${YELLOW}$fullDirectory${NC}
and connect it to the user ${YELLOW}$u${NC}.
"

(git clone git@github.com:Jkutkut/$repoName.git ||
error "not possible to clone")

echo "--------------------------------------
${LGREEN}
Repository cloned${NC}
"


# git@github.com:Jkutkut/ .git