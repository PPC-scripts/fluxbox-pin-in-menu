# fluxbox-pin-in-menu
Small script that allows to pin/unpin applications chosen from .desktop files to the top of the fluxbox menu, for faster access
This was made for, and tested only in antiX Linux, but should work in any linux distribution running a fluxbox desktop.

Note: to run .desktop files directly from Fluxbox menu, this script creates a hidden file in your home folder: ".desktop-run.sh.", that you can use to execute .desktop files from the command line.
(ex: ~/.desktop-run.sh full_path_to_the_file.desktop)

# Instalation:
 Right click https://raw.githubusercontent.com/PPC-scripts/fluxbox-pin-in-menu/master/fb-pin-in-menu.sh and download it to a folder without special characters on your computer.
 Make it executable.
 
 NOTE: you can't run the script from a folder with special characters or it won't create the needed desktop-run.sh correctly: the menu entries will be created but they won't run (strange, I know- I think it's because the script needs to check it's own name and path to generate desktop-run.sh and that does not work well with foregein characters)
  If for some reason that happens, please remove the empty hidden file ".desktop-run.sh" from your home folder, and try again.


Explanation: why do I go to the complicated process of using a script to run .desktop files from the menu instead of also extracting the Exec file from the .desktop files themselves? Simple: so the script can unpin only the applications it pins. based in the string ".desktop", leaving the rest of the menu untouched.

# Dependencies:
 Fluxbox
 
