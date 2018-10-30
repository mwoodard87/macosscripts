#!/bin/csh

#  DataTransfer.sh
#
#  This script was orignally designed for use with macOS User Transfers

#header
echo
echo "macOS User Transfer Utility v1.01"
echo "For IT Staff Only"
echo
echo "Release Notes"
echo "1.01 - Added the function ThunderBoltTransfer"
sleep 1

function ThunderBoltTransfer {
#header
echo
echo "ThunderBoltTransfer Utility v1.0"
echo "Beginning User Backup Process"
sleep 1

#Show list of Users
echo
echo "This is a current list of users on this machine"
ls -lh /Users
sleep 2

#Username Prompt
echo
echo "Please input the username of the User you are going to copy"
read user_to_copy
echo "You entered: $user_to_copy"

#Show User Folder Size
echo
sleep 1
echo "Calculating Home Folder Size. Please Wait.."
du -hs /Users/$user_to_copy

#Prompt for partition on the other computer to copy data to
echo
sleep 1
echo "Please enter the name of the partition from the computer we are transfering to."
echo "This should not have spaces in it. If it does use proper UNIX formatting"
read partition_name
echo "You entered: $partition_name"

#Show remaining space on other computer
echo
echo "The other computer has the following amount of free space left."
FreeSpace=$(diskutil info /Volumes/$partition_name | awk '/Volume Free Space/')
FreeSpaceSierra=$(diskutil info /Volumes/$partition_name | awk '/Volume Available Space/')
echo
if [ -z "$FreeSpace" ]
then
    echo $FreeSpaceSierra
else
    echo $FreeSpace
fi

#Check to see if other computer is mounted
echo
echo "Checking to see if other computer is mounted"
if [ -d "/Volumes/$partition_name" ]
then
	echo "External Drive Detected"
else
	echo "External Drive is not detected. Prompting user to abort. Continuing past warning could yield unexpected results!"
	select yn in "Abort Script" "Continue"; do
		case $yn in
			'Abort Script' ) echo "Aborting Script"; exit;;
			Continue ) break;;
		esac
	done
fi

#Check to see if a backup exists on the backup drive
echo
echo "Checking to see if a previous user backup exists"
if [ -d "/Volumes/$partition_name/Users/$user_to_copy" ]
then
    echo "An existing user folder was found on the transfer machine."

#Prompt to empty trash
echo
echo "Do you wish to empty the trash?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "The trash for $user_to_copy has been emptied."; rm -rf /Users/$user_to_copy/.Trash/*; break;;
        No ) break;;
    esac
done

#Prompt to empty Downloads
echo
echo "Do you wish to empty the downloads folder?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "The downloads for $user_to_copy have been cleared."; rm -rf /Users/$user_to_copy/Downloads/*; break;;
        No ) break;;
    esac
done

#Command confirm
echo
echo "Are you sure you wish to backup this machine?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "The backup process is now underway."; /usr/bin/ditto -V -rsrcFork /Users/$user_to_copy /Volumes/$partition_name/Users/$user_to_copy; fi; break;;
	     No ) echo "The backup process has been cancelled."; exit;;
    esac
done

#Remove Keychain from Backup
echo
echo "Do you wish to remove the Keychains from the User Folder. ONLY DO THIS IF YOU FEEL THE USER FOLDER IS CORRUPTED."
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Removing Keychains from Backup"; rm -rf /Volumes/$partition_name/Users/$user_to_copy/Library/Keychains/*; break;;
        No ) break;;
    esac
done

#Remove Microsoft Office Data Folder
echo
echo "Do You Wish to Remove the Microsoft Office Data Folder from Backup"
echo "Only say NO if the user has groups stored on the local computer"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Removed the Microsoft Office Data Folder from Backup"; rm -rf /Volumes/$partition_name/Users/$user_to_copy/Documents/Microsoft\ Office\ Data/; break;;
        No ) break;;
    esac
done

#Inform User Backup is Complete
echo
echo "The Backup process for the user $user_to_copy has been completed to $partition_name"
}

function UserBackup {
#header
echo
echo "Backup Utility v1.0"
echo "Beginning User Backup Process"
sleep 1

#Show list of Users
echo
echo "This is a current list of users on this machine"
ls -lh /Users
sleep 2

#Username Prompt
echo
echo "Please input the username of the User you are going to copy"
read user_to_copy
echo "You entered: $user_to_copy"

#Show User Folder Size
echo
sleep 1
echo "Calculating Home Folder Size. Please Wait.."
du -hs /Users/$user_to_copy

#Prompt for partition on external drive to copy data to
echo
sleep 1
echo "Please enter the name of the partition on External to copy the user's data to"
echo "This should not have spaces in it. If it does use proper UNIX formatting"
read partition_name
echo "You entered: $partition_name"

#Show remaining space on external drive
echo
echo "The external drive has the following amount of free space left."
FreeSpace=$(diskutil info /Volumes/$partition_name | awk '/Volume Free Space/')
FreeSpaceSierra=$(diskutil info /Volumes/$partition_name | awk '/Volume Available Space/')
echo
if [ -z "$FreeSpace" ]
then
    echo $FreeSpaceSierra
else
    echo $FreeSpace
fi

#Check to see if external drive is mounted
echo
echo "Checking to see if external drive is mounted"
if [ -d "/Volumes/$partition_name" ]
then
	echo "External Drive Detected"
else
	echo "External Drive is not detected. Prompting user to abort. Continuing past warning could yield unexpected results!"
	select yn in "Abort Script" "Continue"; do
		case $yn in
			'Abort Script' ) echo "Aborting Script"; exit;;
			Continue ) break;;
		esac
	done
fi

#Check to see if a backup exists on the backup drive
echo
echo "Checking to see if a previous user backup exists"
if [ -d "/Volumes/$partition_name/Backups/$user_to_copy" ]
then
    echo "A previous backup with the same AD Username was detected"

#Prompt to empty trash
echo
echo "Do you wish to empty the trash?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "The trash for $user_to_copy has been emptied."; rm -rf /Users/$user_to_copy/.Trash/*; break;;
        No ) break;;
    esac
done

#Prompt to empty Downloads
echo
echo "Do you wish to empty the downloads folder?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "The downloads for $user_to_copy have been cleared."; rm -rf /Users/$user_to_copy/Downloads/*; break;;
        No ) break;;
    esac
done

#Command confirm
echo
echo "Are you sure you wish to backup this machine?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "The backup process is now underway."; /usr/bin/ditto -V -rsrcFork /Users/$user_to_copy /Volumes/$partition_name/Backups/$user_to_copy; fi; break;;
	     No ) echo "The backup process has been cancelled."; exit;;
    esac
done

#Remove Keychain from Backup
echo
echo "Do you wish to remove the Keychains from the User Folder. ONLY DO THIS IF YOU FEEL THE USER FOLDER IS CORRUPTED."
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Removing Keychains from Backup"; rm -rf /Volumes/$partition_name/Backups/$user_to_copy/Library/Keychains/*; break;;
        No ) break;;
    esac
done

#Remove Microsoft Office Data Folder
echo
echo "Do You Wish to Remove the Microsoft Office Data Folder from Backup"
echo "Only say NO if the user has groups stored on the local computer"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Removed the Microsoft Office Data Folder from Backup"; rm -rf /Volumes/$partition_name/Backups/$user_to_copy/Documents/Microsoft\ Office\ Data/; break;;
        No ) break;;
    esac
done

#Inform User Backup is Complete
echo
echo "The Backup process for the user $user_to_copy has been completed to $partition_name"
}

function FixPermissions {

#Application Header
echo
printf "\e[1;92mFix Permissions Utility v1.0\e[0m\n"
printf "\e[1;92mBeginning Permission Repair Process\e[0m\n"

#Show list of Users
echo
echo "This is a current list of users on this machine"
ls -lh /Users
sleep 2

#Username Prompt
echo
echo "Please input the username of the User you need to repair permissions for"
read user_to_repair
echo
echo "You entered: $user_to_repair"

#Run username check against Active Directory
echo
ADCheck=$(id $user_to_repair)

#Stop Script for AD Bind Failure / User Lookup
if [ -z "$ADCheck" ]
then
echo
echo "Active Directory Bind check has failed please check the bind status of the machine"
echo
echo "Prompting user to abort. Continuing past warning could yield unexpected results!"
select yn in "Abort Script" "Continue"; do
    case $yn in
        'Abort Script' ) echo "Aborting Script"; exit;;
        Continue ) break;;
    esac
done
sleep 1
fi

#Show Permissions for the requested folder
ls -ld /Users/$user_to_repair

#Command confirm
echo
echo "Are you sure you wish to repair this users permissions?"
select yn in "Yes" "No"; do
case $yn in
Yes ) echo "The permission repair is now underway"; /usr/sbin/chown -R "$user_to_repair:SJUSD\Domain Users" /Users/$user_to_repair; /usr/sbin/chown -R "$user_to_repair:SJUSD\Domain Users" /Users/$user_to_repair/*;
/usr/sbin/chown -R "$user_to_repair:SJUSD\Domain Users" /Users/$user_to_repair/.??*; break;;
No ) echo "The user permission repair process has been cancelled."; exit;;
esac
done

}

function UserRestore {

#header
echo
echo "Restore Utility v1.0"
echo "Beginning User Restore Process"
echo
sleep 1

#External drive Prompt
echo "Please enter the name of the partition on which the backup of the user's data currently resides."
read partition_name
echo "You entered: $partition_name"
sleep 1

#Show list of users in Backup folder
ls -lh /Volumes/$partition_name/Backups/

#Username of Backup Prompt
sleep 1
echo "Please input the username of the Backup being restored"
read user_from_backup
echo "You entered: $user_from_backup"

#Username Prompt
sleep 1
echo "Please input the username of the User you are going to restore"
read aduser
echo "You entered: $aduser"

#Command confirm
echo "Are you sure you wish to restore this backup?"
select yn in "Yes" "No"; do
    case $yn in
Yes ) echo "The restore process is now underway."; /bin/mkdir /Users/$aduser; /usr/sbin/chown "$aduser:SJUSD\Domain Users" /Users/$aduser; /bin/chmod 770 /Users/$aduser; /usr/bin/ditto -V -rsrcFork /Volumes/$partition_name/Backups/$user_from_backup /Users/$aduser; /usr/sbin/chown -R "$aduser:SJUSD\Domain Users" /Users/$aduser/*;
/usr/sbin/chown -R "$aduser:SJUSD\Domain Users" /Users/$aduser/.??*; break;;
        No ) exit;;
    esac
done

#Complete
echo "The restore process of the user $aduser has been completed"

}

#Options
while getopts bfrT: option
do 	case "$option" in
	b)	UserBackup;;
	f)  FixPermissions;;
    r)	UserRestore;;
    t) ThunderBoltTransfer;;
    T)  ;;
	[?])	echo >&2 "Usage: $0 [-b UserBackup] [-f FixPermissions] [-r UserRestore] [-t ThunderBoltTransfer]"
		exit 1;;
	esac
done

#Print Error Message with no arguments
if [ $OPTIND -eq 1 ];
then
echo "*********************************"
echo "Warning No Arguments were entered"
echo "Here is a list of the Arguments"
echo ""
echo "-b User Backup"
echo "-f Fix Permissions"
echo "-r User Restore"
echo "-t ThunderBolt Transfer"
echo "*********************************"
exit
fi
#
#  Designed by Woodard, Michael on 10/24/16
