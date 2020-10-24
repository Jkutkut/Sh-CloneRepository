# Sh-CloneRepository-ssh:

This Shell Script file enable us to clone (or fork) a repository from github without using the git syntax.

**Disclaimer:** please do the [quick setup](#Quick-setup) before using this code for the first time.

## How it works:
Run the command ```./cloneRepo.sh``` or ```sh cloneRepo.sh``` to start the program.  
Once the code is running, type the name of the repository you want to clone and press the "enter" key. That's it, done. It is really that simple.

![Main screen](Res/main-screen.png)

They are some extra features to boost the experience:

### Settings menu:
However, you can change some settings before cloning the repository (typing ```settings``` when asked for the name of the repository):

![Settings-menu](Res/settings.png)

### List menu:
Furthermore, you can select the repository from your account by using the option ```list``` instead of typing it manually (specially usefull when you don't remember the exact name). Once selected, this screen will appear:

![Repository-list](Res/list-repo.png)

In order to select it, use the arrows _UP_ and _DOWN_ to navigate and the _ENTER_ key to select it.

**Note**: If you want to fork the selected repository, just add the fork argument like this example:
    
    ./cloneRepo.sh fork


## Quick setup:
In order to boost this code, please consider following this steps:
- Constants declaration:
    - Add your Git username.
    - Add the default directory to store the repository.
    
    This can be accomplished modifying the following code:

    ```
    # Constants:
    u="Jkutkut"; # Default user name
    fullDirectory=~/github/; # Default dir to store the repository
    ```
- List mode:  
Please install jq, a simple Command-line JSON processor, which will come in handy. This can be acomplished by the use of the command:

        sudo apt install jq

    We have different ways to get the repositories:

    - Auto: This option connects directly to github and gets the names of the repositories avalible automatically and dynamically. This way, a simple selection menu will appear where you can select the repository you want to clone.  
    There are two situations here: Getting the repositories from our account and getting them from other's. To accomplish the first one, using a Github's Personal access token will provide us also with the private repositories from our account (use [this link](https://github.com/settings/tokens) to get it). This way, in both cases we can get all the repositories easily.  
    To enable this feature, uncomment the following code and overwrite "XXXXXXX" with the token (use this feature at your own risk):
    ```
    if [ $u = $defUser ]; then
      # If the user has not being changed using the settings option: use the credentials to get the private repositories
      curl -H "Authorization: token XXXXXXXXXXXXXXXXXXXXXXXXXX" -s "https://api.github.com/search/repositories?q=user:$u&type:all&per_page=100" |
      jq '.items|.[]|.full_name' | cut -d'/' -f 2 | sed 's/.$//' | sort;
    else # If user not changed: use no credentials
      curl -s "https://api.github.com/search/repositories?q=user:$u&type:all&per_page=100" |
      jq '.items|.[]|.full_name' | cut -d'/' -f 2 | sed 's/.$//' | sort;
    fi
    ```  
    **Note**: In order to skip adding the token, just uncomment the lines under the else stament.





    - Manual: This option uses as repository names the lines of a file given. This features enables an easy setup for different Git servers.
    To activate this feature, modify the name of the file in the following line (In this example, the name used is repositorios.txt):
    ```
    cp repositorios.txt temp.txt; # Option 2
    ```
- Option to fork:  
This code can fork the selected repository by the use of the hub command. Please installing using:
    
      sudo apt install hub 