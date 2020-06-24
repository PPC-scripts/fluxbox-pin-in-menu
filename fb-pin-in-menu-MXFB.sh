#! /bin/bash
#`grep '^Exec' $1 | tail -1 | sed 's/^Exec=//' | sed 's/%.//' | sed 's/^"//g' | sed 's/" *$//g'` &
# v. test2 generates menu entries with the application name extracted from the .desktop file. 
# Also, shows after the all the .desktop files on /usr/share/applications/, shows .dekstop files in the /antix subfolder
# I concatenate both .dekstop files and present them in alfabetical order, I choose to not mix both "common" and antix specific applications
# this version of the script tries to add a *.png icon. If it fails, no problem, the menu entry works, but without any icon!
####  
#Application to pin and unpin applications to the top of Fluxbox menu
# requeriments: yad and the executable script "~/desktop-run.sh"
# that script's content is as follows (remove the # at the start of the line):
#`grep '^Exec' $1 | tail -1 | sed 's/^Exec=//' | sed 's/%.//' | sed 's/^"//g' | sed 's/" *$//g'` &
#
# By PPC - 25/01/2020 - GPL licence- do what you want with this script, please keep this comments about the author and date
# TO DO: a option reorder the "pinned" applications
# -- idea1- present the list of pinned applications, like in the "unpin" funtion. When user clicks on, use sed or whatever, to get the selections line number, a new yad window pops up, presenting the line number, allowing to user to increase or decrease the number. Delete current entry, create one at the chosen line number - This will take more work than the pin and unpined functions combined!
#idea2- simply create a button that executes flux menu editor, the user can then move the pinned applications using drag and drop! 
#
#Declare Functions

#IF no "desktop-run.sh" exists int he home folder, create one:
cd ~
file="desktop-run.sh"
if [ ! -f $file ]; then
 echo "desktop-run.sh not found"
   me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
   #the number in the sed command referes to the line from this script to be inserted in "desktop-run.sh" 
   command=$(sed "2q;d" $me)
   echo $command > ~/desktop-run.txt
   echo file content:
   cat ~/desktop-run.txt
   #removing the first character: "#" and save the file as a .sh
    tail -c +2 ~/desktop-run.txt > ~/.desktop-run.sh
   rm ~/desktop-run.txt
echo script content:
cat ~/.desktop-run.sh
chmod u+x ~/.desktop-run.sh
 fi

pin()
{
# creates a list of all installed .desktop files, saved in .apps.txt
cd /usr/share/applications/
find *.desktop > ~/.apps-normal.txt
cd /usr/share/applications/antix
find *.desktop > ~/.apps-antiX.txt
cat ~/.apps-normal.txt  ~/.apps-antiX.txt > ~/.apps.txt
# Use a Yad window to select file to be added to the menu
EXEC=$(yad --title="Select Application to pin to Menu" --width=470 --height=460 --center --separator=" " --list  --column=  < ~/.apps.txt)
#get application name:
app_path='/usr/share/applications/'
full_path=$(echo $app_path$EXEC)
#chech if the selected .desktop file is in the /antiX subfolder, if it is, correct the full path:
 if test -f "$full_path"; then
    echo "the file exists"
   else  app_path='/usr/share/applications/antix/'
 fi
 full_path=$(echo $app_path$EXEC) 
#try to get application icon, assuming it's a png file and int the default icon path:
icon_path="/usr/share/icons/papirus-antix/48x48/apps/"
icon_extension=".png"
icon=$(grep '^Icon=' $full_path | tail -1 | sed 's/^Icon=//' )
icon_with_path=$(echo $icon_path$icon$icon_extension)
##### new part to search for valid icon:
	 app_icon=$(grep '^Icon=' $full_path | head -1 | tail -1 | sed 's/^Icon=//' )
	 ICON00=$(echo "$app_icon" | cut -f1 -d" ")

# if a icon with a full path exists on the .desktop, use that icon, if not assume the icon is a .png file in the icon_path
if [[ -f "$app_icon" ]]; then  icon=$app_icon
 else
  icon=$icon_with_path
fi

#...Also check if the icon's name exists in several possible default paths, if a existing icon is found, use that instead!
#We can add as many paths as we want for the system to look for icons, also, we can look for icons with extensions other than .png (ex: svg), adding new "extension" and path's, and repeating the if-fi cicle
extension=".png"
path="/usr/share/pixmaps/"
ICONwithoutpath=$(basename $icon)
if [[ -f "$path$ICONwithoutpath$extension" ]]; then  icon=$path$ICONwithoutpath$extension
fi

path="/usr/share/icons/papirus-antix/24x24/apps/"
if [[ -f "$path$ICONwithoutpath$extension" ]]; then  icon=$path$ICONwithoutpath$extension
fi

path="/usr/share/icons/papirus-antix/24x24/places/"
if [[ -f "$path$ICONwithoutpath$extension" ]]; then  icon=$path$ICONwithoutpath$extension
fi

path="/usr/share/icons/hicolor/scalable/apps/"
extension2=".svg"
if [[ -f "$path$ICONwithoutpath$extension2" ]]; then  icon=$path$ICONwithoutpath$extension2
fi


#### end of search for valid icon 

#generate menu entry
app_name=$(grep '^Name=' $full_path | head -1 | tail -1 | sed 's/^Name=//' )
foo="[exec] ("
foo="${foo}"${app_name}""")"" {~/.desktop-run.sh ${app_path}${EXEC}} <$icon>"
# insert this generated new line at line 2, but first check, and only add a entry if something was selected"
if test -z "$EXEC" 
then
      echo "nothing was seleted"
else
      sed  -i "2 i\\$foo" ~/.fluxbox/menu-mx
fi
}
################################################
unpin()
{
# generate a list of all pinned aplications (searchs for the string #.desktop ", created by the pinning script
			grep -E '.desktop ' ~/.fluxbox/menu-mx > ~/current_apps_pinned_to_menu.txt
### make choices easier to read- show just app.desktop:
# show only everything between brakets
cat ~/current_apps_pinned_to_menu.txt | cut -d "{" -f2 | cut -d "}" -f1 > ~/temp0
# remove the first XX characters from each line, the "...desktop-run /path" part
sed -i 's/\(.\{42\}\)//' ~/temp0
# Use a Yad window to select file to be removed from the menu
EXEC=$(yad --title="List of apps you can unpin from the Menu" --width=470 --height=460 --center --separator=" " --list  --column=  < ~/temp0)
# delete selected pinned application from the menu, but first check, and only add a entry if something was selected
if test -z "$EXEC" 
then
      echo "nothing was seleted"
else
#remove selected pinned application
# The "cat" command lists the output of the file "menu", the "grep -v" command removes all the lines that have the selected_app_name.desktop, the output is sent to filename.1
	cat ~/.fluxbox/menu-mx | grep -v $EXEC > ~/filename.1
	mv ~/filename.1 ~/.fluxbox/menu-mx
fi	
}
##########################################################
# Main part of the script
# makes the previous created funtions available
export -f pin unpin
# menu to select options:
yad \
    --title "Pin and unpin apps to Fluxbox menu" --width=470 --height=400 \
    --center --text="\n \n This is a quick way to add or remove Applications to the top of the menu, for faster access, using the application's .desktop files.\n \n The 'Pin' button shows a list of the applications .desktop files installed on your system.\n First it lists 'common' applications, then antiX specific or 'system configuration' applications\n  Scroll down until you see the app you want to pin, double left click it.\n \n The 'Unpin' button shows a list of the applications .desktop files pinned to the menu. \n This does not remove any 'normal' menu entries, only the ones related to .desktop files. \n \n IMPORTANT: Always have a back up copy of your  ~/.fluxbox/menu file!" \
    --button="Pin":"bash -c pin" \
    --button="Unpin":"bash -c unpin" \
    --button="Exit":0
echo $?

#####

