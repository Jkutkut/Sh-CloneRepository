# Sh-CloneRepository-ssh:

This Shell Script file enable us to clone a repository from our github without using the git syntax.

**Disclaimer:** please do the quick setup before using this code for the first time.

## How it works:

Once the code is running, type the name of the repository you want to clone and press the "enter" key. That's it, done. It is really that simple.

![Main screen](Res/main-screen.png)

However, you can change some settings before cloning the repository (typing ```settings``` when asked for the name of the repository), such us:
- User name: 
- Directory to store the repository on your device:

Furthermore, you can select the repository from your account by using the option ```list``` instead of typing it manually (specially usefull when you don't remember the exact name). Once selected, this screen will appear:

![Repository-list](Res/list-repo.png)

In order to select it, use the arrows _UP_ and _DOWN_ to navigate and the _ENTER_ key to select it.


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

    We have different ways to get the repositories:
    - Auto: This option connects directly to your github account and gets the names of the repositories automatically and dynamically. This way, once selected the list mode, all the actual repositories on your Github account.
    To activate this feature, the SSH protocol and a Github's Personal access token are neccesary: the following code will be uncommented and the token should be filled (replace XXXXX with the token, and use it at your own risk):
    ```
        curl -u $u:XXXXXXXXXXXXXXXXXXXXXX -s "https://api.github.com/users/$u/repos?type=all&per_page=100" | jq '.[]|.full_name' | cut -d'/' -f 2 | sed 's/.$//' >> temp.txt; # Option 1
    ```
    - Manual: This option uses as repository names the lines of a file given. This features enables an easy setup for different Git servers.
    To activate this feature, modify the name of the file in the following line (In this example, the name used is repositorios.txt):
    ```
        cp repositorios.txt temp.txt; # Option 2
    ```