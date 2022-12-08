#!/bin/bash

#    Copyright (C) 2022 7thCore
#    This file is part of SfSrv-Script.
#
#    SfSrv-Script is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    SfSrv-Script is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

#Satisfactory server script by 7thCore
#If you do not know what any of these settings are you are better off leaving them alone. One thing might brake the other if you fiddle around with it.

#Static script variables
export NAME="SfSrv" #Name of the tmux session.
export VERSION="1.3-1" #Package and script version.
export SERVICE_NAME="sfsrv" #Name of the service files, user, script and script log.
export LOG_DIR="/srv/$SERVICE_NAME/logs" #Location of the script's log files.
export LOG_STRUCTURE="$LOG_DIR/$(date +"%Y")/$(date +"%m")/$(date +"%d")" #Folder structure of the script's log files.
export LOG_SCRIPT="$LOG_STRUCTURE/$SERVICE_NAME-script.log" #Script log.
SRV_DIR="/srv/$SERVICE_NAME/server" #Location of the server located on your hdd/ssd.
TMPFS_DIR="/srv/$SERVICE_NAME/tmpfs" #Locaton of your tmpfs partition.
CONFIG_DIR="/srv/$SERVICE_NAME/config" #Location of script configuration.
ENV_DIR="/srv/$SERVICE_NAME/environments" #Location of server environment configurations.
UPDATE_DIR="/srv/$SERVICE_NAME/updates" #Location of update information for the script's automatic update feature.
BCKP_DIR="/srv/$SERVICE_NAME/backups" #Location of stored backups.
BCKP_STRUCTURE="$(date +"%Y")/$(date +"%m")/$(date +"%d")" #How backups are sorted, by default it's sorted in folders by month and day.

#SteamCmd variables
APPID="1690800" #Steam app id for the server

#Script config file variables
BCKP_DELOLD=$(cat $CONFIG_DIR/$SERVICE_NAME-script.conf 2> /dev/null | grep script_bckp_delold= | cut -d = -f2) #Defines how many days old backups are deleted.
LOG_DELOLD=$(cat $CONFIG_DIR/$SERVICE_NAME-script.conf 2> /dev/null | grep script_log_delold= | cut -d = -f2) #Defines how many days old logs are deleted.
LOG_GAME_DELOLD=$(cat $CONFIG_DIR/$SERVICE_NAME-script.conf 2> /dev/null | grep script_log_game_delold= | cut -d = -f2) #Defines how many days old games logs are deleted.
GAME_SERVER_UPDATES=$(cat $CONFIG_DIR/$SERVICE_NAME-script.conf 2> /dev/null | grep script_update_game= | cut -d = -f2) #Defines if automatic game updates are active.
UPDATE_IGNORE_FAILED_ACTIVATIONS=$(cat $CONFIG_DIR/$SERVICE_NAME-script.conf 2> /dev/null | grep script_update_ignore_failed_startups= | cut -d = -f2) #Defines if errors during startup after updates should be ignored.
TIMEOUT_SAVE=$(cat $CONFIG_DIR/$SERVICE_NAME-script.conf 2> /dev/null | grep script_timeout_save= | cut -d = -f2) #Defines how much time in seconds the script waits for the certain functions to complete.
TMPFS_SPACE=$(cat $CONFIG_DIR/$SERVICE_NAME-script.conf 2> /dev/null | grep script_tmpfs_space= | cut -d = -f2) #Defines how much can the tmpfs parition be filled until an automatic server shutdown is issued.

#Script config variables if config doesn't exist
BCKP_DELOLD=${BCKP_DELOLD:="7"} #If the variable for old backup deletion is not defined, assign a default value.
LOG_DELOLD=${LOG_DELOLD:="7"} #If the variable for old log deletion is not defined, assign a default value.
LOG_GAME_DELOLD=${LOG_GAME_DELOLD:="7"} #If the variable for old game log deletion is not defined, assign a default value.
GAME_SERVER_UPDATES=${GAME_SERVER_UPDATES:="0"} #If the variable for game server updates is not defined, assign a default value.
UPDATE_IGNORE_FAILED_ACTIVATIONS=${UPDATE_IGNORE_FAILED_ACTIVATIONS:="0"} #If the variable for ignoring errors after updates is not defined, assign a default value.
TIMEOUT_SAVE=${TIMEOUT_SAVE:="120"} #If the variable for save timeout is not defined, assign a default value.
TMPFS_SPACE=${TMPFS_SPACE:="90"} #If the variable for tmpfs space is not defined, assign a default value.

#Discord config file variables
DISCORD_UPDATE=$(cat $CONFIG_DIR/$SERVICE_NAME-discord.conf 2> /dev/null | grep discord_update= | cut -d = -f2) #Send notification when the server updates.
DISCORD_START=$(cat $CONFIG_DIR/$SERVICE_NAME-discord.conf 2> /dev/null | grep discord_start= | cut -d = -f2) #Send notifications when the server starts.
DISCORD_STOP=$(cat $CONFIG_DIR/$SERVICE_NAME-discord.conf 2> /dev/null | grep discord_stop= | cut -d = -f2) #Send notifications when the server stops.
DISCORD_CRASH=$(cat $CONFIG_DIR/$SERVICE_NAME-discord.conf 2> /dev/null | grep discord_crash= | cut -d = -f2) #Send notifications when the server crashes.
DISCORD_TMPFS_SPACE=$(cat $CONFIG_DIR/$SERVICE_NAME-discord.conf 2> /dev/null | grep discord_tmpfs_space= | cut -d = -f2) #Send notifications if tmpfs space is over the designated percentage.
DISCORD_COLOR_PRESTART=$(cat $CONFIG_DIR/$SERVICE_NAME-discord.conf 2> /dev/null | grep discord_color_prestart= | cut -d = -f2) #Discord embed color for prestart.
DISCORD_COLOR_POSTSTART=$(cat $CONFIG_DIR/$SERVICE_NAME-discord.conf 2> /dev/null | grep discord_color_poststart= | cut -d = -f2) #Discord embed color for poststart.
DISCORD_COLOR_PRESTOP=$(cat $CONFIG_DIR/$SERVICE_NAME-discord.conf 2> /dev/null | grep discord_color_prestop= | cut -d = -f2) #Discord embed color for prestop.
DISCORD_COLOR_POSTSTOP=$(cat $CONFIG_DIR/$SERVICE_NAME-discord.conf 2> /dev/null | grep discord_color_poststop= | cut -d = -f2) #Discord embed color for poststop.
DISCORD_COLOR_UPDATE=$(cat $CONFIG_DIR/$SERVICE_NAME-discord.conf 2> /dev/null | grep discord_color_update= | cut -d = -f2) #Discord embed color for update.
DISCORD_COLOR_CRASH=$(cat $CONFIG_DIR/$SERVICE_NAME-discord.conf 2> /dev/null | grep discord_color_crash= | cut -d = -f2) #Discord embed color for crash.
DISCORD_COLOR_TMPFS_SPACE=$(cat $CONFIG_DIR/$SERVICE_NAME-discord.conf 2> /dev/null | grep discord_color_tmpfs_space= | cut -d = -f2) #Discord embed color for tmpfs space.

#Discord config variables if config doesn't exist
DISCORD_UPDATE=${DISCORD_UPDATE:="0"} #If the variable for discord update is not defined, assign a default value.
DISCORD_START=${DISCORD_START:="0"} #If the variable for discord start is not defined, assign a default value.
DISCORD_STOP=${DISCORD_STOP:="0"} #If the variable for discord stop is not defined, assign a default value.
DISCORD_CRASH=${DISCORD_CRASH:="0"} #If the variable for discord crash is not defined, assign a default value.
DISCORD_TMPFS_SPACE=${DISCORD_TMPFS_SPACE:="0"} #If the variable for discord tmpfs space is not defined, assign a default value.
DISCORD_COLOR_PRESTART=${DISCORD_COLOR_PRESTART:="16776960"} #If the variable discord pre-start color is not defined, assign a default value.
DISCORD_COLOR_POSTSTART=${DISCORD_COLOR_POSTSTART:="65280"} #If the variable discord post-start color is not defined, assign a default value.
DISCORD_COLOR_PRESTOP=${DISCORD_COLOR_PRESTOP:="16776960"} #If the variable discord pre-stop color is not defined, assign a default value.
DISCORD_COLOR_POSTSTOP=${DISCORD_COLOR_POSTSTOP:="65280"} #If the variable discord post-stop color is not defined, assign a default value.
DISCORD_COLOR_UPDATE=${DISCORD_COLOR_UPDATE:="47083"} #If the variable discord update color is not defined, assign a default value.
DISCORD_COLOR_CRASH=${DISCORD_COLOR_CRASH:="16711680"} #If the variable for discord crash color is not defined, assign a default value.
DISCORD_COLOR_TMPFS_SPACE=${DISCORD_COLOR_TMPFS_SPACE:="16711680"} #If the variable for discord tmpfs space color is not defined, assign a default value.

#Email config file variables
EMAIL_SENDER=$(cat $CONFIG_DIR/$SERVICE_NAME-email.conf 2> /dev/null | grep email_sender= | cut -d = -f2) #Send emails from this address.
EMAIL_RECIPIENT=$(cat $CONFIG_DIR/$SERVICE_NAME-email.conf 2> /dev/null | grep email_recipient= | cut -d = -f2) #Send emails to this address.
EMAIL_UPDATE=$(cat $CONFIG_DIR/$SERVICE_NAME-email.conf 2> /dev/null | grep email_update= | cut -d = -f2) #Send emails when server updates.
EMAIL_START=$(cat $CONFIG_DIR/$SERVICE_NAME-email.conf 2> /dev/null | grep email_start= | cut -d = -f2) #Send emails when the server starts up.
EMAIL_STOP=$(cat $CONFIG_DIR/$SERVICE_NAME-email.conf 2> /dev/null | grep email_stop= | cut -d = -f2) #Send emails when the server shuts down.
EMAIL_CRASH=$(cat $CONFIG_DIR/$SERVICE_NAME-email.conf 2> /dev/null | grep email_crash= | cut -d = -f2) #Send emails when the server crashes.
EMAIL_TMPFS_SPACE=$(cat $CONFIG_DIR/$SERVICE_NAME-email.conf 2> /dev/null | grep email_tmpfs_space= | cut -d = -f2) #Send emails if tmpfs space is over the designated percentage.

#Email config variables if config doesn't exist
EMAIL_SENDER=${EMAIL_SENDER:="none"} #If the variable for email sender is not defined, assign a default value.
EMAIL_RECIPIENT=${EMAIL_RECIPIENT:="none"} #If the variable for email recipient is not defined, assign a default value.
EMAIL_UPDATE=${EMAIL_UPDATE:="0"} #If the variable for email update is not defined, assign a default value.
EMAIL_START=${EMAIL_START:="0"} #If the variable for email start is not defined, assign a default value.
EMAIL_STOP=${EMAIL_STOP:="0"} #If the variable for email stop is not defined, assign a default value.
EMAIL_CRASH=${EMAIL_CRASH:="0"} #If the variable for email crash is not defined, assign a default value.
EMAIL_TMPFS_SPACE=${EMAIL_TMPFS_SPACE:="0"} #If the variable for email tmpfs space is not defined, assign a default value.

#Console collors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
LIGHTRED='\033[1;31m'
NC='\033[0m'

#--------------------------
#-- End of configuration --
#--------------------------

#Generate log folder structure
script_logs() {
	#If there is not a folder for today, create one
	if [ ! -d "$LOG_STRUCTURE" ]; then
		mkdir -p "$LOG_STRUCTURE"
	fi
}

#--------------------------

#Discord webhook message send
script_discord_message() {
	while IFS="" read -r DISCORD_WEBHOOK || [ -n "$DISCORD_WEBHOOK" ]; do
		curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"author\": { \"name\": \"$NAME Script\", \"url\": \"https://github.com/7thCore/$SERVICE_NAME-script\" }, \"color\": \"$1\", \"description\": \"$2\", \"footer\": {\"text\": \"Version $VERSION\"}, \"timestamp\": \"$(date -u --iso-8601=seconds)\"}] }" "$DISCORD_WEBHOOK"
	done < $CONFIG_DIR/discord_webhooks.txt
}

#--------------------------

#Send email message
script_email_message() {
	mail -r "$EMAIL_SENDER ($1)" -s "$2" $EMAIL_RECIPIENT <<- EOF
	$3
	EOF
}

#--------------------------

#Attaches to the server tmux session
script_attach() {
	if [ -z "$1" ]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Attach) Failed to attach. Specify server ID: $SCRIPT_NAME -attach ID" | tee -a "$LOG_SCRIPT"
	else
		tmux -L $SERVICE_NAME-$1-tmux.sock has-session -t $NAME 2>/dev/null
		if [ $? == 0 ]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Attach) User attached to server session with ID: $1" | tee -a "$LOG_SCRIPT"
			tmux -L $SERVICE_NAME-$1-tmux.sock attach -t $NAME
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Attach) User deattached from server session with ID: $1" | tee -a "$LOG_SCRIPT"
		else
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Attach) Failed to attach to server session with ID: $1" | tee -a "$LOG_SCRIPT"
		fi
	fi
}

#--------------------------

#Deletes old files
script_remove_old_files() {
	script_logs
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Remove old files) Beginning removal of old files." | tee -a "$LOG_SCRIPT"
	#Delete old logs
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Remove old files) Removing old script logs: $LOG_DELOLD days old." | tee -a "$LOG_SCRIPT"
	find $LOG_DIR/* -mtime +$LOG_DELOLD -delete
	#Delete empty folders
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Remove old files) Removing empty script log folders." | tee -a "$LOG_SCRIPT"
	find $LOG_DIR/ -type d -empty -delete
	IFS=","
	for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager --plain $SERVICE_NAME@*.service $SERVICE_NAME-tmpfs@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
		SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Remove old files) Deleting old backups for $SERVER_INSTANCE: $BCKP_DELOLD days old." | tee -a "$LOG_SCRIPT"
			# Delete old backups
			find $BCKP_DIR/$SERVER_INSTANCE/* -type f -mtime +$BCKP_DELOLD -delete
			# Delete empty folders
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Remove old files) Deleting empty backup folders for $SERVER_INSTANCE." | tee -a "$LOG_SCRIPT"
			find $BCKP_DIR/$SERVER_INSTANCE/ -type d -empty -delete
		fi
	done
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Remove old files) Removal of old files complete." | tee -a "$LOG_SCRIPT"
}

#--------------------------

#Prints out if the server is running
script_status() {
	script_logs
	IFS=","
	for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager --plain $SERVICE_NAME@*.service $SERVICE_NAME-tmpfs@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
		SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "inactive" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Status) Server $SERVER_INSTANCE is not running." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Status) Server $SERVER_INSTANCE is running." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "failed" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Status) Server $SERVER_INSTANCE is in failed state. Please check logs." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "activating" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Status) Server $SERVER_INSTANCE is activating. Please wait." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "deactivating" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Status) Server $SERVER_INSTANCE is in deactivating. Please wait." | tee -a "$LOG_SCRIPT"
		fi
	done
	if pidof -x "$SCRIPT_PID_CHECK" -o $$ > /dev/null; then
		echo "Is another instance of the script running?: YES"
	else
		echo "Is another instance of the script running?: NO"
	fi
}

#--------------------------

#Adds a server instance to the server list file
script_add_server() {
	script_logs

	#Downloads game files
	script_add_server_current_download() {
		if [ ! -d "$UPDATE_DIR/$1" ]; then
			mkdir -p "$UPDATE_DIR/$1"
		fi
		steamcmd +login anonymous +app_info_update 1 +app_info_print $APPID +quit > $UPDATE_DIR/steam_app_data.txt

		INSTALLED_BUILDID=$(cat $UPDATE_DIR/steam_app_data.txt | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"public\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"buildid\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3)
		echo "$INSTALLED_BUILDID" > $UPDATE_DIR/$1/installed.buildid

		INSTALLED_TIME=$(cat $UPDATE_DIR/steam_app_data.txt | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"public\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"timeupdated\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3)

		echo "$INSTALLED_TIME" > $UPDATE_DIR/$1/installed.timeupdated
		steamcmd +force_install_dir $SRV_DIR/$1/ +login anonymous +app_update $APPID validate +quit
	}

	#Downloads game files
	script_add_server_beta_download() {
		if [ ! -d "$UPDATE_DIR/$1" ]; then
			mkdir -p "$UPDATE_DIR/$1"
		fi
		steamcmd +login anonymous +app_info_update 1 +app_info_print $APPID +quit > $UPDATE_DIR/steam_app_data.txt

		INSTALLED_BUILDID=$(cat $UPDATE_DIR/steam_app_data.txt | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"$2\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"buildid\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3)
		echo "$INSTALLED_BUILDID" > $UPDATE_DIR/$1/installed.buildid

		INSTALLED_TIME=$(cat $UPDATE_DIR/steam_app_data.txt | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"$2\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"timeupdated\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3)
		echo "$INSTALLED_TIME" > $UPDATE_DIR/$1/installed.timeupdated

		echo "steamcmd_beta_branch=$2" > $UPDATE_DIR/$1/beta.txt
		steamcmd +force_install_dir $SRV_DIR/$1/ +login anonymous +app_update $APPID -beta $2 validate +quit
	}

	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Add server instance) User adding new server instance." | tee -a "$LOG_SCRIPT"
	read -p "Are you sure you want to add a server instance? (y/n): " ADD_SERVER_INSTANCE_ADD
	if [[ "$ADD_SERVER_INSTANCE_ADD" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		echo ""
		echo "List of current servers (your new server instance must NOT be identical to any of them!):"
		if [ ! -f $CONFIG_DIR/$SERVICE_NAME-server-list.txt ] ; then
			touch $CONFIG_DIR/$SERVICE_NAME-server-list.txt
		fi
		cat $CONFIG_DIR/$SERVICE_NAME-server-list.txt
		echo ""
		read -p "Specify your server instance (Can be a number or string. Eamples: 01, current_latest or beta): " SERVER_INSTANCE_ADD
		echo ""

		echo "Specify your server instance branch (leave empty for current/latest): "
		echo "You can check branch names here: https://steamdb.info/app/$APPID/depots/"
		read -p "Branch: " SERVER_INSTANCE_ADD_TYPE
		echo ""

		read -p "Enable tmpfs for this server? (y/n): " SERVER_INSTANCE_ADD_TMPFS

		echo ""
		read -p "Do you want to download the latest server files from Steam servers? (y/n): " SERVER_INSTANCE_ADD_DOWNLOAD
		read -p "Enable automatic updates from Steam servers for this instance? (y/n): " SERVER_INSTANCE_ADD_UPDATES

		echo ""
		read -p "Enter the query port for your server: " SERVER_QUERY_PORT
		read -p "Enter the beacon port for your server: " SERVER_BEACON_PORT
		read -p "Enter the game port for your server: " SERVER_GAME_PORT

		echo "QUERY_PORT=$SERVER_QUERY_PORT" > $ENV_DIR/${SERVER_INSTANCE_ADD}.env
		echo "BEACON_PORT=$SERVER_BEACON_PORT" >> $ENV_DIR/${SERVER_INSTANCE_ADD}.env
		echo "GAME_PORT=$SERVER_GAME_PORT" >> $ENV_DIR/${SERVER_INSTANCE_ADD}.env

		mkdir "$SRV_DIR/$SERVER_INSTANCE_ADD"

		if [[ "$SERVER_INSTANCE_ADD_TMPFS" =~ ^([yY][eE][sS]|[yY])$ ]]; then
			if [[ -z "$SERVER_INSTANCE_ADD_TYPE" ]]; then
				if [[ "$SERVER_INSTANCE_ADD_DOWNLOAD" =~ ^([yY][eE][sS]|[yY])$ ]]; then
					script_add_server_current_download $SERVER_INSTANCE_ADD
				fi
				if [[ "$SERVER_INSTANCE_ADD_UPDATES" =~ ^([yY][eE][sS]|[yY])$ ]]; then
					echo "$SERVICE_NAME-tmpfs@$SERVER_INSTANCE_ADD.service" >> $CONFIG_DIR/$SERVICE_NAME-server-update-list.txt
				fi
			else
				if [[ "$SERVER_INSTANCE_ADD_DOWNLOAD" =~ ^([yY][eE][sS]|[yY])$ ]]; then
					script_add_server_beta_download $SERVER_INSTANCE_ADD $SERVER_INSTANCE_ADD_TYPE
				fi
				if [[ "$SERVER_INSTANCE_ADD_UPDATES" =~ ^([yY][eE][sS]|[yY])$ ]]; then
					echo "$SERVICE_NAME-tmpfs@$SERVER_INSTANCE_ADD.service" >> $CONFIG_DIR/$SERVICE_NAME-server-update-list.txt
				fi
			fi
			echo "$SERVICE_NAME-tmpfs@$SERVER_INSTANCE_ADD.service" >> $CONFIG_DIR/$SERVICE_NAME-server-list.txt
			systemctl --user enable --now $SERVICE_NAME-mkdir-tmpfs@$SERVER_INSTANCE_ADD.service
			systemctl --user enable $SERVICE_NAME-tmpfs@$SERVER_INSTANCE_ADD.service
		else
			if [[ -z "$SERVER_INSTANCE_ADD_TYPE" ]]; then
				if [[ "$SERVER_INSTANCE_ADD_DOWNLOAD" =~ ^([yY][eE][sS]|[yY])$ ]]; then
					script_add_server_current_download $SERVER_INSTANCE_ADD
				fi
				if [[ "$SERVER_INSTANCE_ADD_UPDATES" =~ ^([yY][eE][sS]|[yY])$ ]]; then
					echo "$SERVICE_NAME@$SERVER_INSTANCE_ADD.service" >> $CONFIG_DIR/$SERVICE_NAME-server-update-list.txt
				fi
			else
				if [[ "$SERVER_INSTANCE_ADD_DOWNLOAD" =~ ^([yY][eE][sS]|[yY])$ ]]; then
					script_add_server_beta_download $SERVER_INSTANCE_ADD $SERVER_INSTANCE_ADD_TYPE
				fi
				if [[ "$SERVER_INSTANCE_ADD_UPDATES" =~ ^([yY][eE][sS]|[yY])$ ]]; then
					echo "$SERVICE_NAME@$SERVER_INSTANCE_ADD.service" >> $CONFIG_DIR/$SERVICE_NAME-server-update-list.txt
				fi
			fi
			echo "$SERVICE_NAME@$SERVER_INSTANCE_ADD.service" >> $CONFIG_DIR/$SERVICE_NAME-server-list.txt
			systemctl --user enable $SERVICE_NAME@$SERVER_INSTANCE_ADD.service
		fi
		systemctl --user daemon-reload
		if [ -f "$SRV_DIR/$SERVER_INSTANCE_ADD/Engine/Binaries/Linux/UE4Server-Linux-Shipping" ] || [ -f "$(ls -v --ignore='*.*' $SRV_DIR/$SERVER_INSTANCE_ADD/Engine/Binaries/Linux | grep -i 'UE4Server-Linux-Shipping')" ]; then
			read -p "Server instance $SERVER_INSTANCE_ADD added successfully. Do you want to start it? (y/n): " START_SERVER_INSTANCE_ADD
			if [[ "$START_SERVER_INSTANCE_ADD" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				if [[ "$SERVER_INSTANCE_ADD_TMPFS" =~ ^([yY][eE][sS]|[yY])$ ]]; then
					systemctl --user start $SERVICE_NAME-tmpfs@$SERVER_INSTANCE_ADD.service
				else
					systemctl --user start $SERVICE_NAME@$SERVER_INSTANCE_ADD.service
				fi
			fi
		else
			echo "No supported binary file found. Copy your server files to $SRV_DIR/$SERVER_INSTANCE_ADD and start the server."
		fi
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Add server instance) Server instance $SERVER_INSTANCE_ADD successfully added." | tee -a "$LOG_SCRIPT"
	else
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Add server instance) User canceled adding new server instance." | tee -a "$LOG_SCRIPT"
	fi
}

#--------------------------

#Removes a server instance from the server list file
script_remove_server() {
	script_logs
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Remove server instance) User started removal of server instance." | tee -a "$LOG_SCRIPT"
	read -p "Are you sure you want to remove a server instance? (y/n): " REMOVE_SERVER_INSTANCE
	if [[ "$REMOVE_SERVER_INSTANCE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		IFS=","
		for SERVER_SERVICE in $(cat $CONFIG_DIR/$SERVICE_NAME-server-list.txt | tr "\\n" "," | sed 's/,$//'); do
			SERVER_INSTANCE_LIST=("$SERVER_SERVICE" "${SERVER_INSTANCE_LIST[@]}")
		done
		SERVER_INSTANCE_LIST=("Cancel" "${SERVER_INSTANCE_LIST[@]}")
		select SERVER_INSTANCE in "${SERVER_INSTANCE_LIST[@]}"; do
			SERVER_INSTANCE_REMOVE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
			if [[ "$SERVER_INSTANCE_REMOVE" == "Cancel" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Remove server instance) User canceled removal of server instance." | tee -a "$LOG_SCRIPT"
				break
			fi
			sed -e "s/$SERVER_INSTANCE//g" -i $CONFIG_DIR/$SERVICE_NAME-server-list.txt
			sed '/^$/d' -i $CONFIG_DIR/$SERVICE_NAME-server-list.txt
			sed -e "s/$SERVER_INSTANCE//g" -i $CONFIG_DIR/$SERVICE_NAME-server-update-list.txt
			sed '/^$/d' -i $CONFIG_DIR/$SERVICE_NAME-server-update-list.txt
			if [ -d "/srv/$SERVICE_NAME/.config/systemd/user/$SERVER_INSTANCE.d" ] ; then
				rm -rf /srv/$SERVICE_NAME/.config/systemd/user/$SERVER_INSTANCE.d
			fi
			if [[ "$(systemctl --user show -p UnitFileState --value $SERVICE_NAME-mkdir-tmpfs@$SERVER_INSTANCE_REMOVE.service)" == "enabled" ]]; then
				systemctl --user disable $SERVICE_NAME-mkdir-tmpfs@$SERVER_INSTANCE_REMOVE.service
			fi
			systemctl --user disable $SERVER_INSTANCE
			read -p "Server instance $SERVER_INSTANCE removed successfully. Do you want to stop it? (y/n): " STOP_SERVER_INSTANCE
			if [[ "$STOP_SERVER_INSTANCE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				systemctl --user stop $SERVER_INSTANCE
				read -p "Delete the server folder for $SERVER_INSTANCE_REMOVE? (y/n): " DELETE_SERVER_INSTANCE
				if [[ "$DELETE_SERVER_INSTANCE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
					rm -rf $SRV_DIR/$SERVER_INSTANCE_REMOVE
				fi
			fi
			read -p "Delete the backup folder for $SERVER_INSTANCE_REMOVE? (y/n): " DELETE_SERVER_BACKUP
			if [[ "$DELETE_SERVER_BACKUP" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				rm -rf $BCKP_DIR/$SERVER_INSTANCE_REMOVE
			fi
			read -p "Delete the environment file for $SERVER_INSTANCE_REMOVE? (y/n): " DELETE_SERVER_ENV_FILE
			if [[ "$DELETE_SERVER_ENV_FILE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				rm $ENV_DIR/${SERVER_INSTANCE_REMOVE}.env
			fi
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Remove server instance) Server instance $SERVER_INSTANCE_REMOVE successfully removed." | tee -a "$LOG_SCRIPT"
			break
		done
	else
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Remove server instance) User canceled removal of server instance." | tee -a "$LOG_SCRIPT"
	fi
}

#--------------------------

#Disable all script services
script_disable_services() {
	script_logs
	IFS=","
	for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager --plain $SERVICE_NAME@*.service $SERVICE_NAME-tmpfs@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
		SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		if [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			systemctl --user disable $SERVER_SERVICE
			if [[ "$(systemctl --user show -p UnitFileState --value $SERVICE_NAME-mkdir-tmpfs@$SERVER_INSTANCE.service)" == "enabled" ]]; then
				systemctl --user disable $SERVICE_NAME-mkdir-tmpfs@$SERVER_INSTANCE.service
			fi
		fi
	done
	if [[ "$(systemctl --user show -p UnitFileState --value $SERVICE_NAME-timer-1.timer)" == "enabled" ]]; then
		systemctl --user disable --now $SERVICE_NAME-timer-1.timer
	fi
	if [[ "$(systemctl --user show -p UnitFileState --value $SERVICE_NAME-timer-2.timer)" == "enabled" ]]; then
		systemctl --user disable --now $SERVICE_NAME-timer-2.timer
	fi
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Disable services) Services successfully disabled." | tee -a "$LOG_SCRIPT"
}

#--------------------------

#Disables all script services, available to the user
script_disable_services_manual() {
	script_logs
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Disable services) WARNING: This will disable all script services. The server will be disabled." | tee -a "$LOG_SCRIPT"
	read -p "Are you sure you want to disable all services? (y/n): " DISABLE_SCRIPT_SERVICES
	if [[ "$DISABLE_SCRIPT_SERVICES" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		script_disable_services
	elif [[ "$DISABLE_SCRIPT_SERVICES" =~ ^([nN][oO]|[nN])$ ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Disable services) Disable services canceled." | tee -a "$LOG_SCRIPT"
	fi
}

#--------------------------

# Enable script services by reading the configuration file
script_enable_services() {
	script_logs
	IFS=","
	for SERVER_SERVICE in $(cat $CONFIG_DIR/$SERVICE_NAME-server-list.txt | tr "\\n" "," | sed 's/,$//'); do
		SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		if [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "disabled" ]]; then
			systemctl --user enable $SERVER_SERVICE
		fi
		if [[ "$(systemctl --user show -p UnitFileState --value $SERVICE_NAME-tmpfs@$SERVER_INSTANCE)" == "disabled" ]];then
			systemctl --user enable $SERVICE_NAME-mkdir-tmpfs@$SERVER_INSTANCE.service
		fi
	done
	if [[ "$(systemctl --user show -p UnitFileState --value $SERVICE_NAME-timer-1.timer)" == "disabled" ]]; then
		systemctl --user enable --now $SERVICE_NAME-timer-1.timer
	fi
	if [[ "$(systemctl --user show -p UnitFileState --value $SERVICE_NAME-timer-2.timer)" == "disabled" ]]; then
		systemctl --user enable --now $SERVICE_NAME-timer-2.timer
	fi
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Enable services) Services successfully Enabled." | tee -a "$LOG_SCRIPT"
}

#--------------------------

# Enable script services by reading the configuration file, available to the user
script_enable_services_manual() {
	script_logs
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Enable services) This will enable all script services. All added servers will be enabled." | tee -a "$LOG_SCRIPT"
	read -p "Are you sure you want to enable all services? (y/n): " ENABLE_SCRIPT_SERVICES
	if [[ "$ENABLE_SCRIPT_SERVICES" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		script_enable_services
	elif [[ "$ENABLE_SCRIPT_SERVICES" =~ ^([nN][oO]|[nN])$ ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Enable services) Enable services canceled." | tee -a "$LOG_SCRIPT"
	fi
}

#--------------------------

#Disables all script services an re-enables them by reading the configuration file
script_reload_services() {
	script_logs
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Reload services) This will reload all script services." | tee -a "$LOG_SCRIPT"
	read -p "Are you sure you want to reload all services? (y/n): " RELOAD_SCRIPT_SERVICES
	if [[ "$RELOAD_SCRIPT_SERVICES" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		script_disable_services
		systemctl --user daemon-reload
		systemctl --user reset-failed
		script_enable_services
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Reload services) Reload services complete." | tee -a "$LOG_SCRIPT"
	elif [[ "$RELOAD_SCRIPT_SERVICES" =~ ^([nN][oO]|[nN])$ ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Reload services) Reload services canceled." | tee -a "$LOG_SCRIPT"
	fi
}

#--------------------------

#Sync server files from ramdisk to hdd/ssd
script_sync() {
	script_logs
	IFS=","
	for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager --plain $SERVICE_NAME-tmpfs@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
		SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" != "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Sync) Server $SERVER_INSTANCE is not running." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Sync) Sync from tmpfs to disk for server $SERVER_INSTANCE has been initiated." | tee -a "$LOG_SCRIPT"
			rsync -aAX --info=progress2 $TMPFS_DIR/$SERVER_INSTANCE/ $SRV_DIR/$SERVER_INSTANCE
			sleep 1
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Sync) Sync from tmpfs to disk for server $SERVER_INSTANCE has been completed." | tee -a "$LOG_SCRIPT"
		fi
	done
}

#--------------------------

#Checks the space occupied on the tmpfs partition and if it's over the user designated value, shuts down tmpfs servers
script_tmpfs_space_check() {
	script_logs
	CURRENT_TMPFS_SPACE=$(df -H | grep "$TMPFS_DIR" | awk '{print $5}' | cut -d'%' -f1)
	if [ $CURRENT_TMPFS_SPACE -ge $TMPFS_SPACE ] ; then
		if [[ "$DISCORD_TMPFS_SPACE" == "1" ]]; then
			script_discord_message "$DISCORD_COLOR_TMPFS_SPACE" "The tmpfs partition is $CURRENT_TMPFS_SPACE percent filled. Automatic shutdown of tmpfs servers has been initiated."
		fi
		if [[ "$EMAIL_TMPFS_SPACE" == "1" ]]; then
			script_email_message "$NAME-$1" "Notification: Tmpfs running out of space" "The tmpfs partition is $CURRENT_TMPFS_SPACE percent filled. Automatic shutdown of tmpfs servers has been initiated."
		fi
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Tmpfs space check) The tmpfs partition is at $CURRENT_TMPFS_SPACE percent filled.  Automatic shutdown of tmpfs servers has been initiated." | tee -a "$LOG_SCRIPT"
		IFS=","
		for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager --plain $SERVICE_NAME-tmpfs@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
			SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
			if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				script_stop $SERVER_SERVICE
			fi
		done
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Tmpfs space check) Shutdown of tmpfs servers complete." | tee -a "$LOG_SCRIPT"
	fi
}

#--------------------------

#Pre-start functions to be called by the systemd service
script_prestart() {
	script_logs
	if [[ "$DISCORD_START" == "1" ]]; then
		script_discord_message "$DISCORD_COLOR_PRESTART" "Server startup for $1 was initialized."
	fi
	if [[ "$EMAIL_START" == "1" ]]; then
		script_email_message "$NAME-$1" "Notification: Server startup $1" "Server startup for $1 was initialized at $(date +"%d.%m.%Y %H:%M:%S")"
	fi
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Start) Server startup for $1 was initialized." | tee -a "$LOG_SCRIPT"

	if [[ "$2" == "tmpfs" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Start) Sync from disk to tmpfs for $1 has been initiated." | tee -a "$LOG_SCRIPT"
		if [ -d "$SRV_DIR/$1" ]; then
			rsync -aAX --info=progress2 $SRV_DIR/$1/ $TMPFS_DIR/$1
		fi
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Start) Sync from disk to tmpfs for $1 complete." | tee -a "$LOG_SCRIPT"
	fi
}

#--------------------------

#Post-start functions to be called by the systemd service
script_poststart() {
	script_logs
	if [[ "$DISCORD_START" == "1" ]]; then
		script_discord_message "$DISCORD_COLOR_POSTSTART" "Server startup for $1 complete."
	fi
	if [[ "$EMAIL_START" == "1" ]]; then
		script_email_message "$NAME-$1" "Notification: Server startup $1" "Server startup for $1 was completed at $(date +"%d.%m.%Y %H:%M:%S")"
	fi
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Start) Server startup for $1 complete." | tee -a "$LOG_SCRIPT"
}

#--------------------------

#Pre-stop functions to be called by the systemd service
script_prestop() {
	script_logs
	if [[ "$DISCORD_STOP" == "1" ]]; then
		script_discord_message "$DISCORD_COLOR_PRESTOP" "Server shutdown for $1 was initialized."
	fi
	if [[ "$EMAIL_STOP" == "1" ]]; then
		script_email_message "$NAME-$1" "Notification: Server shutdown $1" "Server shutdown was initiated at $(date +"%d.%m.%Y %H:%M:%S")"
	fi
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Stop) Server shutdown for $1 was initialized." | tee -a "$LOG_SCRIPT"
}

#--------------------------

#Pre-stop functions to be called by the systemd service
script_peristop() {
	SERVICE_PID=$(/usr/bin/tmux -L $SERVICE_NAME-$1-tmux.sock list-panes -t $NAME -F '#{pane_pid}')
	/usr/bin/kill -s SIGTERM $SERVICE_PID
	sleep 5
	/usr/bin/kill -s SIGTERM $SERVICE_PID
}

#--------------------------

#Post-stop functions to be called by the systemd service
script_poststop() {
	script_logs

	#Check if the server is still running, if it is wait for it to stop.
	while true; do
		tmux -L $SERVICE_NAME-$1-tmux.sock has-session -t $NAME 2>/dev/null
		if [ $? -eq 1 ]; then
			break
		fi
		sleep 1
	done

	if [[ "$2" == "tmpfs" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Start) Sync from tmpfs to disk for $1 has been initiated." | tee -a "$LOG_SCRIPT"
		if [ -d "$TMPFS_DIR/$1" ]; then
			rsync -aAX --info=progress2 $TMPFS_DIR/$1/ $SRV_DIR/$1
		fi
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Start) Sync from tmpfs to disk for $1 complete." | tee -a "$LOG_SCRIPT"
	fi

	if [ -f "/tmp/$SERVICE_NAME-$1-tmux.log" ]; then
		rm /tmp/$SERVICE_NAME-$1-tmux.log
	fi

	if [ -f "/tmp/$SERVICE_NAME-$1-tmux.conf" ]; then
		rm /tmp/$SERVICE_NAME-$1-tmux.conf
	fi

	if [[ "$DISCORD_STOP" == "1" ]]; then
		script_discord_message "$DISCORD_COLOR_POSTSTOP" "Server shutdown for $1 complete."
	fi
	if [[ "$EMAIL_STOP" == "1" ]]; then
		script_email_message "$NAME-$1" "Notification: Server shutdown $1" "Server shutdown was complete at $(date +"%d.%m.%Y %H:%M:%S")"
	fi
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Stop) Server shutdown for $1 complete." | tee -a "$LOG_SCRIPT"
}

#--------------------------

#Start the server
script_start() {
	script_logs

	#Loop until the server is active and output the state of it
	script_start_loop() {
		SERVER_INSTANCE_LOOP=$(echo $1 | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		while [[ "$(systemctl --user show -p ActiveState --value $1)" == "activating" ]] && [[ "$(systemctl --user show -p UnitFileState --value $1)" == "enabled" ]]; do
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Start) Server $SERVER_INSTANCE_LOOP is activating. Please wait..." | tee -a "$LOG_SCRIPT"
			sleep 1
		done
		if [[ "$(systemctl --user show -p ActiveState --value $1)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $1)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Start) Server $SERVER_INSTANCE_LOOP has been successfully activated." | tee -a "$LOG_SCRIPT"
			sleep 1
		elif [[ "$(systemctl --user show -p ActiveState --value $1)" == "failed" ]] && [[ "$(systemctl --user show -p UnitFileState --value $1)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Start) Server $SERVER_INSTANCE_LOOP failed to activate. See systemctl --user status $1 for details." | tee -a "$LOG_SCRIPT"
			sleep 1
		fi
	}

	if [[ -z "$1" ]] || [[ "$1" == "ignore" ]]; then
		IFS=","
		for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager --plain $SERVICE_NAME@*.service $SERVICE_NAME-tmpfs@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
			SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
			if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "inactive" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Start) Server $SERVER_INSTANCE start initialized." | tee -a "$LOG_SCRIPT"
				systemctl --user start $SERVER_SERVICE
				script_start_loop $SERVER_SERVICE
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Start) Server $SERVER_INSTANCE is already running." | tee -a "$LOG_SCRIPT"
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "failed" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Start) Server $SERVER_INSTANCE is in failed state. See systemctl --user status $SERVER_SERVICE for details." | tee -a "$LOG_SCRIPT"
				if [[ "$1" == "ignore" ]]; then
					systemctl --user start $SERVER_SERVICE
					script_start_loop $SERVER_SERVICE
				else
					read -p "Do you still want to start the server? (y/n): " FORCE_START
					if [[ "$FORCE_START" =~ ^([yY][eE][sS]|[yY])$ ]]; then
						systemctl --user start $SERVER_SERVICE
						script_start_loop $SERVER_SERVICE
					fi
				fi
			fi
		done
	else
		IFS=","
		for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager --plain $SERVICE_NAME@$1.service $SERVICE_NAME-tmpfs@$1.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
			SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
			if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "inactive" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Start) Server $1 start initialized." | tee -a "$LOG_SCRIPT"
				systemctl --user start $SERVER_SERVICE
				script_start_loop $SERVER_SERVICE
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Start) Server $1 is already running." | tee -a "$LOG_SCRIPT"
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "failed" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Start) Server $1 is in failed state. See systemctl --user status $SERVER_SERVICE for details." | tee -a "$LOG_SCRIPT"
				if [[ "$2" == "ignore" ]]; then
					systemctl --user start $SERVER_SERVICE
					script_start_loop $SERVER_SERVICE
				else
					read -p "Do you still want to start the server? (y/n): " FORCE_START
					if [[ "$FORCE_START" =~ ^([yY][eE][sS]|[yY])$ ]]; then
						systemctl --user start $SERVER_SERVICE
						script_start_loop $SERVER_SERVICE
					fi
				fi
			fi
		done
	fi
}

#--------------------------

#Stop the server
script_stop() {
	script_logs

	#Loop until the server is inactive and output the state of it
	script_stop_loop() {
		SERVER_INSTANCE_LOOP=$(echo $1 | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		while [[ "$(systemctl --user show -p ActiveState --value $1)" == "deactivating" ]]; do
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Stop) Server $SERVER_INSTANCE_LOOP is deactivating. Please wait..." | tee -a "$LOG_SCRIPT"
			sleep 1
		done
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Stop) Server $SERVER_INSTANCE_LOOP is deactivated." | tee -a "$LOG_SCRIPT"
	}

	if [ -z "$1" ]; then
		IFS=","
		for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager --plain $SERVICE_NAME@*.service $SERVICE_NAME-tmpfs@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
			SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
			if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "inactive" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Stop) Server $SERVER_INSTANCE is not running." | tee -a "$LOG_SCRIPT"
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "failed" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Stop) Server $SERVER_INSTANCE is in failed state. Please check logs." | tee -a "$LOG_SCRIPT"
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Stop) Server $SERVER_INSTANCE shutdown in progress." | tee -a "$LOG_SCRIPT"
				systemctl --user stop $SERVER_SERVICE
				script_stop_loop $SERVER_SERVICE
			fi
		done
	else
		IFS=","
		for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager --plain $SERVICE_NAME@$1.service $SERVICE_NAME-tmpfs@$1.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
			SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
			if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "inactive" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Stop) Server $SERVER_INSTANCE is not running." | tee -a "$LOG_SCRIPT"
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "failed" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Stop) Server $SERVER_INSTANCE is in failed state. Please check logs." | tee -a "$LOG_SCRIPT"
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Stop) Server $SERVER_INSTANCE shutdown in progress." | tee -a "$LOG_SCRIPT"
				systemctl --user stop $SERVER_SERVICE
				script_stop_loop $SERVER_SERVICE
			fi
		done
	fi
}

#--------------------------

#Restart the server
script_restart() {
	script_logs
	if [ -z "$1" ]; then
		IFS=","
		for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager --plain $SERVICE_NAME@*.service $SERVICE_NAME-tmpfs@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
			SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
			if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "inactive" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Restart) Server $SERVER_INSTANCE is not running. Execute $SERVICE_NAME-script start to start the server." | tee -a "$LOG_SCRIPT"
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "activating" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Restart) Server $SERVER_INSTANCE is activating. Aborting restart." | tee -a "$LOG_SCRIPT"
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "deactivating" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Restart) Server $SERVER_INSTANCE is in deactivating. Aborting restart." | tee -a "$LOG_SCRIPT"
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Restart) Server $SERVER_INSTANCE is going to restart in 15-30 seconds, please wait..." | tee -a "$LOG_SCRIPT"
				sleep 1
				script_stop $SERVER_INSTANCE
				sleep 1
				script_start $SERVER_INSTANCE
				sleep 1
			fi
		done
	else
		IFS=","
		for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager --plain $SERVICE_NAME@$1.service $SERVICE_NAME-tmpfs@$1.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
			if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "inactive" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Restart) Server $SERVER_INSTANCE is not running. Execute $SERVICE_NAME-script start to start the server." | tee -a "$LOG_SCRIPT"
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "activating" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Restart) Server $SERVER_INSTANCE is activating. Aborting restart." | tee -a "$LOG_SCRIPT"
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "deactivating" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Restart) Server $SERVER_INSTANCE is in deactivating. Aborting restart." | tee -a "$LOG_SCRIPT"
			elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Restart) Server $SERVER_INSTANCE is going to restart in 15-30 seconds, please wait..." | tee -a "$LOG_SCRIPT"
				sleep 1
				script_stop $SERVER_INSTANCE
				sleep 1
				script_start $SERVER_INSTANCE
				sleep 1
			fi
		done
	fi
}

#--------------------------

#Systemd service sends email if email notifications for crashes enabled
script_send_notification_crash() {
	script_logs
	CRASH_TIME=$(date +"%Y-%m-%d_%H-%M")
	if [ ! -d "$LOG_STRUCTURE/Server-$1-crash_$CRASH_TIME" ]; then
		mkdir -p "$LOG_STRUCTURE/Server-$1-crash_$CRASH_TIME"
	fi

	if [[ "$(systemctl --user show -p UnitFileState --value $SERVICE_NAME-tmpfs@$1.service)" == "enabled" ]]; then
		systemctl --user status $SERVICE_NAME-tmpfs@$1.service > $LOG_STRUCTURE/Server-$1-crash_$CRASH_TIME/service_log.txt
		find "$TMPFS_DIR/$1/logs/" -maxdepth 1 -type f \( ! -iname "*.gz" \) -mmin -30 -exec zip $LOG_STRUCTURE/Server-$1-crash_$CRASH_TIME/game_logs.zip -j {} +
	elif [[ "$(systemctl --user show -p UnitFileState --value $SERVICE_NAME@$1.service)" == "enabled" ]]; then
		systemctl --user status $SERVICE_NAME@$1.service > $LOG_STRUCTURE/Server-$1-crash_$CRASH_TIME/service_log.txt
		find "$SRV_DIR/$1/logs/" -maxdepth 1 -type f \( ! -iname "*.gz" \) -mmin -30 -exec zip $LOG_STRUCTURE/Server-$1-crash_$CRASH_TIME/game_logs.zip -j {} +
	fi

	zip -j $LOG_STRUCTURE/Server-$1-crash_$CRASH_TIME/service_logs.zip $LOG_STRUCTURE/Server-$1-crash_$CRASH_TIME/service_log.txt
	zip -j $LOG_STRUCTURE/Server-$1-crash_$CRASH_TIME/script_logs.zip $LOG_SCRIPT
	rm $LOG_STRUCTURE/Server-$1-crash_$CRASH_TIME/service_log.txt

	if [[ "$EMAIL_CRASH" == "1" ]]; then
		mail -a $LOG_STRUCTURE/Server-$1-crash_$CRASH_TIME/service_logs.zip -a $LOG_STRUCTURE/Server-$1-crash_$CRASH_TIME/script_logs.zip -a $LOG_STRUCTURE/Server-$1-crash_$CRASH_TIME/game_logs.zip -r "$EMAIL_SENDER ($NAME $SERVICE_NAME)" -s "Notification: Server $1 crash" $EMAIL_RECIPIENT <<- EOF
		The $NAME server $1 crashed 3 times in the last 5 minutes. Automatic restart is disabled and the server is inactive. Please check the logs for more information.

		Attachment contents:
		service_logs.zip - Logs from the systemd service
		script_logs.zip - Logs from the script
		game_logs.zip - Logs from the game
		EOF
	fi

	if [[ "$DISCORD_CRASH" == "1" ]]; then
		script_discord_message "$DISCORD_COLOR_CRASH" "Server $1 crashed 3 times in the last 5 minutes.\nAutomatic restart is disabled and the server is inactive.\n\nPlease review your logs located in $LOG_STRUCTURE/Server-$1-crash_$CRASH_TIME."
	fi
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Crash) Server $1 crashed. Please review your logs located in $LOG_STRUCTURE/Server-$1-crash_$CRASH_TIME." | tee -a "$LOG_SCRIPT"
}

#--------------------------

#Creates a backup of the server
script_backup() {
	script_logs

	#If there is not a folder for today, create one
	script_backup_create_folder() {
		if [ ! -d "$BCKP_DIR/$1/$BCKP_STRUCTURE" ]; then
			mkdir -p "$BCKP_DIR/$1/$BCKP_STRUCTURE"
		fi
	}

	#Backup source to destination
	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Backup) Backup has been initiated." | tee -a  "$LOG_SCRIPT"

	NUMBER_OF_ACTIVE_UNITS=0

	for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager --plain $SERVICE_NAME-tmpfs@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
		SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" != "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Autobackup) Server $SERVER_INSTANCE is not running." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			NUMBER_OF_ACTIVE_UNITS=$(($NUMBER_OF_ACTIVE_UNITS+1))
		fi
	done
	for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager --plain $SERVICE_NAME@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
		SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" != "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Autobackup) Server $SERVER_INSTANCE is not running." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			NUMBER_OF_ACTIVE_UNITS=$(($NUMBER_OF_ACTIVE_UNITS+1))
		fi
	done

	if [ "$var" -ge "1" ]; then
		script_backup_create_folder $SERVER_INSTANCE
		cd /srv/$SERVICE_NAME/.config/Epic/FactoryGame/Saved/SaveGames
		tar -cpvzf $BCKP_DIR/$BCKP_STRUCTURE/$(date +"%Y%m%d%H%M").tar.gz /srv/$SERVICE_NAME/.config/Epic/FactoryGame/Saved/SaveGames/
	fi

	echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Backup) Backup complete." | tee -a  "$LOG_SCRIPT"
}

#--------------------------

#Check for updates. If there are updates available, shut down the server, update it and restart it.
script_update() {
	script_logs
	IFS=","
	for SERVER_SERVICE in $(cat $CONFIG_DIR/$SERVICE_NAME-server-update-list.txt | tr "\\n" "," | sed 's/,$//'); do
		SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Update) Initializing update check for server $SERVER_INSTANCE." | tee -a "$LOG_SCRIPT"

		if [ ! -d "$UPDATE_DIR/$SERVER_INSTANCE" ]; then
			mkdir -p "$UPDATE_DIR/$SERVER_INSTANCE"
		fi

		if [ ! -f $UPDATE_DIR/$SERVER_INSTANCE/installed.buildid ] ; then
			touch $UPDATE_DIR/$SERVER_INSTANCE/installed.buildid
			echo "0" > $UPDATE_DIR/$SERVER_INSTANCE/installed.buildid
		fi

		if [ ! -f $UPDATE_DIR/$SERVER_INSTANCE/installed.timeupdated ] ; then
			touch $UPDATE_DIR/$SERVER_INSTANCE/installed.timeupdated
			echo "0" > $UPDATE_DIR/$SERVER_INSTANCE/installed.timeupdated
		fi

		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Update) Removing Steam/appcache/appinfo.vdf" | tee -a "$LOG_SCRIPT"
		rm -rf "/srv/$SERVICE_NAME/.steam/appcache/appinfo.vdf"

		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Update) Connecting to steam servers." | tee -a "$LOG_SCRIPT"
		steamcmd +login anonymous +app_info_update 1 +app_info_print $APPID +quit > $UPDATE_DIR/steam_app_data.txt

		if [ ! -f "$UPDATE_DIR/$SERVER_INSTANCE/beta.txt" ]; then
			AVAILABLE_BUILDID=$(cat $UPDATE_DIR/steam_app_data.txt | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"public\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"buildid\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3)
			AVAILABLE_TIME=$(cat $UPDATE_DIR/steam_app_data.txt | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"public\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"timeupdated\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3)
		elif [ -f "$UPDATE_DIR/$SERVER_INSTANCE/beta.txt" ]; then
			STEAMCMD_BETA_BRANCH_NAME=$(cat $UPDATE_DIR/$SERVER_INSTANCE/beta.txt 2> /dev/null | grep steamcmd_beta_branch= | cut -d = -f2)
			AVAILABLE_BUILDID=$(cat $UPDATE_DIR/steam_app_data.txt | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"$STEAMCMD_BETA_BRANCH_NAME\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"buildid\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3)
			AVAILABLE_TIME=$(cat $UPDATE_DIR/steam_app_data.txt | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"$STEAMCMD_BETA_BRANCH_NAME\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"timeupdated\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d' ' -f3)
		fi

		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Update) Received application info data." | tee -a "$LOG_SCRIPT"

		INSTALLED_BUILDID=$(cat $UPDATE_DIR/$SERVER_INSTANCE/installed.buildid)
		INSTALLED_TIME=$(cat $UPDATE_DIR/$SERVER_INSTANCE/installed.timeupdated)

		if [ "$AVAILABLE_TIME" -gt "$INSTALLED_TIME" ]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Update) New update for server $SERVER_INSTANCE detected." | tee -a "$LOG_SCRIPT"
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Update) Server $SERVER_INSTANCE installed BuildID: $INSTALLED_BUILDID, TimeUpdated: $INSTALLED_TIME" | tee -a "$LOG_SCRIPT"
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Update) Server $SERVER_INSTANCE available BuildID: $AVAILABLE_BUILDID, TimeUpdated: $AVAILABLE_TIME" | tee -a "$LOG_SCRIPT"

			if [[ "$DISCORD_UPDATE" == "1" ]]; then
				script_discord_message "$DISCORD_COLOR_UPDATE" "New update detected. Installing update."
			fi

			if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				WAS_ACTIVE="1"
				script_stop $SERVER_INSTANCE
			fi

			if [[ "$(echo $SERVER_SERVICE | awk -F '@' '{print $1}')" == "$SERVICE_NAME-tmpfs" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Update) Deleting TmpFs content." | tee -a "$LOG_SCRIPT"
				rm -rf $TMPFS_DIR/$SERVER_INSTANCE/
			fi

			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Update) Updating server $SERVER_INSTANCE..." | tee -a "$LOG_SCRIPT"

			if [ ! -f "$UPDATE_DIR/$SERVER_INSTANCE/beta.txt" ]; then
				steamcmd +force_install_dir $SRV_DIR/$SERVER_INSTANCE/ +login anonymous +app_update $APPID validate +quit
			elif [ -f "$UPDATE_DIR/$SERVER_INSTANCE/beta.txt" ]; then
				STEAMCMD_BETA_BRANCH_NAME=$(cat $UPDATE_DIR/$SERVER_INSTANCE/beta.txt 2> /dev/null | grep steamcmd_beta_branch= | cut -d = -f2)
				steamcmd +force_install_dir $SRV_DIR/$SERVER_INSTANCE/ +login anonymous +app_update $APPID -beta $STEAMCMD_BETA_BRANCH_NAME validate +quit
			fi

			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Update) Update completed." | tee -a "$LOG_SCRIPT"
			echo "$AVAILABLE_BUILDID" > $UPDATE_DIR/$SERVER_INSTANCE/installed.buildid
			echo "$AVAILABLE_TIME" > $UPDATE_DIR/$SERVER_INSTANCE/installed.timeupdated

			if [ "$WAS_ACTIVE" == "1" ]; then
				if [[ "$(echo $SERVER_SERVICE | awk -F '@' '{print $1}')" == "$SERVICE_NAME-tmpfs" ]]; then
					mkdir -p "$TMPFS_DIR/$SERVER_INSTANCE"
				fi

				sleep 1
				if [[ "$UPDATE_IGNORE_FAILED_ACTIVATIONS" == "1" ]]; then
					script_start $SERVER_INSTANCE "ignore"
				else
					script_start $SERVER_INSTANCE
				fi
			fi

			if [[ "$DISCORD_UPDATE" == "1" ]]; then
				script_discord_message "$DISCORD_COLOR_UPDATE" "Server update complete."
			fi
			if [[ "$EMAIL_UPDATE" == "1" ]]; then
				script_email_message "$NAME" "Notification: Update" "Server was updated. Please check the update notes if there are any additional steps to take."
			fi
		elif [[ "$JAR_SHA1" == "$INSTALLED_SHA1" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Update) No new updates for server $SERVER_INSTANCE detected." | tee -a "$LOG_SCRIPT"
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Update) Server $SERVER_INSTANCE installed BuildID: $INSTALLED_BUILDID, TimeUpdated: $INSTALLED_TIME" | tee -a "$LOG_SCRIPT"
		fi
	done
}

#--------------------------

#Uses steam to verfy the integrity of the game server files
script_verify_game_integrity() {
	script_logs

	#Verifies game files
	script_verify_game_download() {
		if [ ! -f "$UPDATE_DIR/$1/beta.txt" ]; then
			steamcmd +force_install_dir $SRV_DIR/$1/ +login anonymous $APPID validate +quit
		elif [ -f "$UPDATE_DIR/$1/beta.txt" ]; then
			STEAMCMD_BETA_BRANCH_NAME=$(cat $UPDATE_DIR/$1/beta.txt 2> /dev/null | grep steamcmd_beta_branch= | cut -d = -f2)
			steamcmd +force_install_dir $SRV_DIR/$1/ +login anonymous $APPID -beta $STEAMCMD_BETA_BRANCH_NAME validate +quit
		fi
	}

	if [ -z "$1" ]; then
		IFS=","
		for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager --plain $SERVICE_NAME@*.service $SERVICE_NAME-tmpfs@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
			SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
			if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				WAS_ACTIVE="1"
				script_stop $SERVER_INSTANCE
			fi
			if [[ "$(echo $SERVER_SERVICE | awk -F '@' '{print $1}')" == "$SERVICE_NAME-tmpfs" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Update) Deleting TmpFs content." | tee -a "$LOG_SCRIPT"
				rm -rf $TMPFS_DIR/$SERVER_INSTANCE/
			fi
			script_verify_game_download $SERVER_INSTANCE
			if [ "$WAS_ACTIVE" == "1" ]; then
				if [[ "$(echo $SERVER_SERVICE | awk -F '@' '{print $1}')" == "$SERVICE_NAME-tmpfs" ]]; then
					mkdir -p "$TMPFS_DIR/$SERVER_INSTANCE"
				fi
				sleep 1
				if [[ "$UPDATE_IGNORE_FAILED_ACTIVATIONS" == "1" ]]; then
					script_start $SERVER_INSTANCE "ignore"
				else
					script_start $SERVER_INSTANCE
				fi
			fi
		done
	else
		for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager --plain $SERVICE_NAME@$1.service $SERVICE_NAME-tmpfs@$1.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
			SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
			if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
				WAS_ACTIVE="1"
				script_stop $SERVER_INSTANCE
			fi
			if [[ "$(echo $SERVER_SERVICE | awk -F '@' '{print $1}')" == "$SERVICE_NAME-tmpfs" ]]; then
				echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Update) Deleting TmpFs content." | tee -a "$LOG_SCRIPT"
				rm -rf $TMPFS_DIR/$SERVER_INSTANCE/
			fi
			script_verify_game_download $SERVER_INSTANCE
			if [ "$WAS_ACTIVE" == "1" ]; then
				if [[ "$(echo $SERVER_SERVICE | awk -F '@' '{print $1}')" == "$SERVICE_NAME-tmpfs" ]]; then
					mkdir -p "$TMPFS_DIR/$SERVER_INSTANCE"
				fi
				sleep 1
				if [[ "$UPDATE_IGNORE_FAILED_ACTIVATIONS" == "1" ]]; then
					script_start $SERVER_INSTANCE "ignore"
				else
					script_start $SERVER_INSTANCE
				fi
			fi
		done
	fi
}

#--------------------------

#First timer function for systemd timers to execute parts of the script in order without interfering with each other
script_timer_one() {
	RUNNING_SERVERS="0"
	IFS=","
	for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager --plain $SERVICE_NAME@*.service $SERVICE_NAME-tmpfs@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
		SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "inactive" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Status) Server $SERVER_INSTANCE is not running." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "failed" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Status) Server $SERVER_INSTANCE is in failed state. Please check logs." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "activating" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Status) Server $SERVER_INSTANCE is activating. Aborting until next scheduled execution." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "deactivating" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Status) Server $SERVER_INSTANCE is in deactivating. Aborting until next scheduled execution." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Status) Server $SERVER_INSTANCE is running." | tee -a "$LOG_SCRIPT"
			RUNNING_SERVERS=$(($RUNNING_SERVERS + 1))
		fi
	done

	if [ $RUNNING_SERVERS -gt "0" ]; then
		script_remove_old_files
		script_tmpfs_space_check
		script_sync
		script_backup
		if [[ "$GAME_SERVER_UPDATES" == "1" ]]; then
			script_update
		fi
	fi
}

#--------------------------

#Second timer function for systemd timers to execute parts of the script in order without interfering with each other
script_timer_two() {
	RUNNING_SERVERS="0"
	IFS=","
	for SERVER_SERVICE in $(systemctl --user list-units -all --no-legend --no-pager --plain $SERVICE_NAME@*.service $SERVICE_NAME-tmpfs@*.service | awk '{print $1}' | tr "\\n" "," | sed 's/,$//'); do
		SERVER_INSTANCE=$(echo $SERVER_SERVICE | awk -F '@' '{print $2}' | awk -F '.service' '{print $1}')
		if [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "inactive" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Status) Server $SERVER_INSTANCE is not running." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "failed" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Status) Server $SERVER_INSTANCE is in failed state. Please check logs." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "activating" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Status) Server $SERVER_INSTANCE is activating. Aborting until next scheduled execution." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "deactivating" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Status) Server $SERVER_INSTANCE is in deactivating. Aborting until next scheduled execution." | tee -a "$LOG_SCRIPT"
		elif [[ "$(systemctl --user show -p ActiveState --value $SERVER_SERVICE)" == "active" ]] && [[ "$(systemctl --user show -p UnitFileState --value $SERVER_SERVICE)" == "enabled" ]]; then
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Status) Server $SERVER_INSTANCE is running." | tee -a "$LOG_SCRIPT"
			RUNNING_SERVERS=$(($RUNNING_SERVERS + 1))
		fi
	done

	if [ $RUNNING_SERVERS -gt "0" ]; then
		script_remove_old_files
		script_tmpfs_space_check
		script_sync
		if [[ "$GAME_SERVER_UPDATES" == "1" ]]; then
			script_update
		fi
	fi
}

#--------------------------

#Runs the diagnostics
script_diagnostics() {
	echo "Initializing diagnostics. Please wait..."
	echo ""
	sleep 3

	#Check package versions
	echo "Checkign package versions:"
	if [ -f "/usr/bin/pacman" ]; then
		echo "bash version:$(pacman -Qi bash | grep "^Version" | cut -d : -f2)"
		echo "coreutils version:$(pacman -Qi coreutils | grep "^Version" | cut -d : -f2)"
		echo "sudo version:$(pacman -Qi sudo | grep "^Version" | cut -d : -f2)"
		echo "grep version:$(pacman -Qi grep | grep "^Version" | cut -d : -f2)"
		echo "sed version:$(pacman -Qi sed | grep "^Version" | cut -d : -f2)"
		echo "awk version:$(pacman -Qi awk | grep "^Version" | cut -d : -f2)"
		echo "curl version:$(pacman -Qi curl | grep "^Version" | cut -d : -f2)"
		echo "rsync version:$(pacman -Qi rsync | grep "^Version" | cut -d : -f2)"
		echo "wget version:$(pacman -Qi wget | grep "^Version" | cut -d : -f2)"
		echo "findutils version:$(pacman -Qi findutils | grep "^Version" | cut -d : -f2)"
		echo "tmux version:$(pacman -Qi tmux | grep "^Version" | cut -d : -f2)"
		echo "jq version:$(pacman -Qi jq | grep "^Version" | cut -d : -f2)"
		echo "zip version:$(pacman -Qi zip | grep "^Version" | cut -d : -f2)"
		echo "unzip version:$(pacman -Qi unzip | grep "^Version" | cut -d : -f2)"
		echo "p7zip version:$(pacman -Qi p7zip | grep "^Version" | cut -d : -f2)"
		echo "postfix version:$(pacman -Qi postfix | grep "^Version" | cut -d : -f2)"
		echo "samba version:$(pacman -Qi samba | grep "^Version" | cut -d : -f2)"
	elif [ -f "/usr/bin/dpkg" ]; then
		echo "bash version:$(dpkg -s bash | grep "^Version" | cut -d : -f2)"
		echo "coreutils version:$(dpkg -s coreutils | grep "^Version" | cut -d : -f2)"
		echo "sudo version:$(dpkg -s sudo | grep "^Version" | cut -d : -f2)"
		echo "libpam-systemd version:$(dpkg -s libpam-systemd | grep "^Version" | cut -d : -f2)"
		echo "grep version:$(dpkg -s grep | grep "^Version" | cut -d : -f2)"
		echo "sed version:$(dpkg -s sed | grep "^Version" | cut -d : -f2)"
		echo "gawk version:$(dpkg -s gawk | grep "^Version" | cut -d : -f2)"
		echo "curl version:$(dpkg -s curl | grep "^Version" | cut -d : -f2)"
		echo "rsync version:$(dpkg -s rsync | grep "^Version" | cut -d : -f2)"
		echo "wget version:$(dpkg -s wget | grep "^Version" | cut -d : -f2)"
		echo "findutils version:$(dpkg -s findutils | grep "^Version" | cut -d : -f2)"
		echo "tmux version:$(dpkg -s tmux | grep "^Version" | cut -d : -f2)"
		echo "jq version:$(dpkg -s jq | grep "^Version" | cut -d : -f2)"
		echo "zip version:$(dpkg -s zip | grep "^Version" | cut -d : -f2)"
		echo "unzip version:$(dpkg -s unzip | grep "^Version" | cut -d : -f2)"
		echo "p7zip version:$(dpkg -s p7zip | grep "^Version" | cut -d : -f2)"
		echo "postfix version:$(dpkg -s postfix | grep "^Version" | cut -d : -f2)"
	fi
	echo ""

	echo "Checking if files and folders present:"
	#Check if files/folders present
	if [ -f "/usr/bin/$SERVICE_NAME-script" ] ; then
		echo "Script present: Yes"
	else
		echo "Script present: No"
	fi

	if [ -d "$CONFIG_DIR" ]; then
		echo "Configuration folder present: Yes"
	else
		echo "Configuration folder present: No"
	fi

	if [ -d "$BCKP_DIR" ]; then
		echo "Backups folder present: Yes"
	else
		echo "Backups folder present: No"
	fi

	if [ -d "$LOF_DIR" ]; then
		echo "Logs folder present: Yes"
	else
		echo "Logs folder present: No"
	fi

	if [ -d "$UPDATE_DIR" ]; then
		echo "Updates folder present: Yes"
	else
		echo "Updates folder present: No"
	fi

	if [ -f "$CONFIG_DIR/$SERVICE_NAME-script.conf" ] ; then
		echo "Script configuration file present: Yes"
	else
		echo "Script configuration file present: No"
	fi

	if [ -f "$CONFIG_DIR/$SERVICE_NAME-steam.conf" ] ; then
		echo "Steam configuration file present: Yes"
	else
		echo "Steam configuration file present: No"
	fi

	if [ -f "$CONFIG_DIR/$SERVICE_NAME-discord.conf" ] ; then
		echo "Discord configuration file present: Yes"
	else
		echo "Discord configuration file present: No"
	fi

	if [ -f "$CONFIG_DIR/$SERVICE_NAME-email.conf" ] ; then
		echo "Email configuration file present: Yes"
	else
		echo "Email configuration file present: No"
	fi

	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE_NAME-mkdir-tmpfs@.service" ]; then
		echo "Tmpfs mkdir service present: Yes"
	else
		echo "Tmpfs mkdir service present: No"
	fi

	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE_NAME-tmpfs@.service" ]; then
		echo "Tmpfs service for vanilla present: Yes"
	else
		echo "Tmpfs service for vanilla present: No"
	fi

	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE_NAME@.service" ]; then
		echo "Basic service for vanilla present: Yes"
	else
		echo "Basic service for vanilla present: No"
	fi

	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE_NAME-timer-1.timer" ]; then
		echo "Timer 1 timer present: Yes"
	else
		echo "Timer 1 timer present: No"
	fi

	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE_NAME-timer-1.service" ]; then
		echo "Timer 1 service present: Yes"
	else
		echo "Timer 1 service present: No"
	fi

	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE_NAME-timer-2.timer" ]; then
		echo "Timer 2 timer present: Yes"
	else
		echo "Timer 2 timer present: No"
	fi

	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE_NAME-timer-2.service" ]; then
		echo "Timer 2 service present: Yes"
	else
		echo "Timer 2 service present: No"
	fi

	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE_NAME-serversync@.service" ]; then
		echo "ServerSync service present: Yes"
	else
		echo "ServerSync service present: No"
	fi

	if [ -f "/srv/$SERVICE_NAME/.config/systemd/user/$SERVICE_NAME-send-notification@.service" ]; then
		echo "Notification sending service present: Yes"
	else
		echo "Notification sending service present: No"
	fi

	echo "Diagnostics complete."
}

#--------------------------

#Install tmux configuration for specific server when first ran
script_server_tmux_install() {
	if [ -z "$2" ]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Server tmux configuration) Installing tmux configuration for server $1." | tee -a "$LOG_SCRIPT"
		TMUX_CONFIG_FILE="/tmp/$SERVICE_NAME-$1-tmux.conf"
	elif [[ "$2" == "override" ]]; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Server tmux configuration) Installing tmux override configuration for server $1." | tee -a "$LOG_SCRIPT"
		TMUX_CONFIG_FILE="$CONFIG_DIR/$SERVICE_NAME-$1-tmux.conf"
	fi

	if [ -f $CONFIG_DIR/$SERVICE_NAME-$1-tmux.conf ]; then
		cp $CONFIG_DIR/$SERVICE_NAME-$1-tmux.conf /tmp/$SERVICE_NAME-$1-tmux.conf
	else
		if [ ! -f $TMUX_CONFIG_FILE ]; then
			touch $TMUX_CONFIG_FILE
			cat > $TMUX_CONFIG_FILE <<- EOF
			#Tmux configuration
			set -g activity-action other
			set -g allow-rename off
			set -g assume-paste-time 1
			set -g base-index 0
			set -g bell-action any
			set -g default-command "${SHELL}"
			#set -g default-terminal "tmux-256color"
			set -g default-terminal "screen-hack_color"
			set -g default-shell "/bin/bash"
			set -g default-size "132x42"
			set -g destroy-unattached off
			set -g detach-on-destroy on
			set -g display-panes-active-colour red
			set -g display-panes-colour blue
			set -g display-panes-time 1000
			set -g display-time 3000
			set -g history-limit 10000
			set -g key-table "root"
			set -g lock-after-time 0
			set -g lock-command "lock -np"
			set -g message-command-style fg=yellow,bg=black
			set -g message-style fg=black,bg=yellow
			set -g mouse on
			#set -g prefix C-b
			set -g prefix2 None
			set -g renumber-windows off
			set -g repeat-time 500
			set -g set-titles off
			set -g set-titles-string "#S:#I:#W - \"#T\" #{session_alerts}"
			set -g silence-action other
			set -g status on
			set -g status-bg green
			set -g status-fg black
			set -g status-format[0] "#[align=left range=left #{status-left-style}]#{T;=/#{status-left-length}:status-left}#[norange default]#[list=on align=#{status-justify}]#[list=left-marker]<#[list=right-marker]>#[list=on]#{W:#[range=window|#{window_index} #{window-status-style}#{?#{&&:#{window_last_flag},#{!=:#{window-status-last-style},default}}, #{window-status-last-style},}#{?#{&&:#{window_bell_flag},#{!=:#{window-status-bell-style},default}}, #{window-status-bell-style},#{?#{&&:#{||:#{window_activity_flag},#{window_silence_flag}},#{!=:#{window-status-activity-style},default}}, #{window-status-activity-style},}}]#{T:window-status-format}#[norange default]#{?window_end_flag,,#{window-status-separator}},#[range=window|#{window_index} list=focus #{?#{!=:#{window-status-current-style},default},#{window-status-current-style},#{window-status-style}}#{?#{&&:#{window_last_flag},#{!=:#{window-status-last-style},default}}, #{window-status-last-style},}#{?#{&&:#{window_bell_flag},#{!=:#{window-status-bell-style},default}}, #{window-status-bell-style},#{?#{&&:#{||:#{window_activity_flag},#{window_silence_flag}},#{!=:#{window-status-activity-style},default}}, #{window-status-activity-style},}}]#{T:window-status-current-format}#[norange list=on default]#{?window_end_flag,,#{window-status-separator}}}#[nolist align=right range=right #{status-right-style}]#{T;=/#{status-right-length}:status-right}#[norange default]"
			set -g status-format[1] "#[align=centre]#{P:#{?pane_active,#[reverse],}#{pane_index}[#{pane_width}x#{pane_height}]#[default] }"
			set -g status-interval 15
			set -g status-justify left
			set -g status-keys emacs
			set -g status-left "[#S] "
			set -g status-left-length 10
			set -g status-left-style default
			set -g status-position bottom
			set -g status-right "#{?window_bigger,[#{window_offset_x}#,#{window_offset_y}] ,}\"#{=21:pane_title}\" %H:%M %d-%b-%y"
			set -g status-right-length 40
			set -g status-right-style default
			set -g status-style fg=black,bg=green
			set -g update-environment[0] "DISPLAY"
			set -g update-environment[1] "KRB5CCNAME"
			set -g update-environment[2] "SSH_ASKPASS"
			set -g update-environment[3] "SSH_AUTH_SOCK"
			set -g update-environment[4] "SSH_AGENT_PID"
			set -g update-environment[5] "SSH_CONNECTION"
			set -g update-environment[6] "WINDOWID"
			set -g update-environment[7] "XAUTHORITY"
			set -g visual-activity off
			set -g visual-bell off
			set -g visual-silence off
			set -g word-separators " -_@"

			#Change prefix key from ctrl+b to ctrl+a
			unbind C-b
			set -g prefix C-a
			bind C-a send-prefix

			#Bind C-a r to reload the config file
			bind-key r source-file /tmp/$SERVICE_NAME-$1-tmux.conf \; display-message "Config reloaded!"

			set-hook -g session-created 'resize-window -y 24 -x 10000'
			set-hook -g session-created "pipe-pane -o 'tee >> /tmp/$SERVICE_NAME-$1-tmux.log'"
			set-hook -g client-attached 'resize-window -y 24 -x 10000'
			set-hook -g client-detached 'resize-window -y 24 -x 10000'
			set-hook -g client-resized 'resize-window -y 24 -x 10000'

			#Default key bindings (only here for info)
			#Ctrl-b l (Move to the previously selected window)
			#Ctrl-b w (List all windows / window numbers)
			#Ctrl-b <window number> (Move to the specified window number, the default bindings are from 0 – 9)
			#Ctrl-b q  (Show pane numbers, when the numbers show up type the key to goto that pane)

			#Ctrl-b f <window name> (Search for window name)
			#Ctrl-b w (Select from interactive list of windows)

			#Copy/ scroll mode
			#Ctrl-b [ (in copy mode you can navigate the buffer including scrolling the history. Use vi or emacs-style key bindings in copy mode. The default is emacs. To exit copy mode use one of the following keybindings: vi q emacs Esc)
			EOF
			echo "$(date +"%Y-%m-%d %H:%M:%S") [$VERSION] [$NAME] (Server tmux configuration) Tmux configuration for server $1 installed successfully." | tee -a "$LOG_SCRIPT"
		fi
	fi
}

#--------------------------

#Configures discord integration
script_config_discord() {
	echo ""
	read -p "Enable discord notifications (y/n): " INSTALL_DISCORD_ENABLE
	if [[ "$INSTALL_DISCORD_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		echo ""
		echo "You are able to add multiple webhooks for the script to use in the discord_webhooks.txt file located in the config folder."
		echo "EACH ONE HAS TO BE IN IT'S OWN LINE!"
		echo ""
		read -p "Enter your first webhook for the server: " INSTALL_DISCORD_WEBHOOK
		if [[ "$INSTALL_DISCORD_WEBHOOK" == "" ]]; then
			INSTALL_DISCORD_WEBHOOK="none"
		fi
		echo ""
		read -p "Discord notifications for game updates? (y/n): " INSTALL_DISCORD_UPDATE_ENABLE
			if [[ "$INSTALL_DISCORD_UPDATE_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_DISCORD_UPDATE="1"
			else
				INSTALL_DISCORD_UPDATE="0"
			fi
		echo ""
		read -p "Discord notifications for server startup? (y/n): " INSTALL_DISCORD_START_ENABLE
			if [[ "$INSTALL_DISCORD_START_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_DISCORD_START="1"
			else
				INSTALL_DISCORD_START="0"
			fi
		echo ""
		read -p "Discord notifications for server shutdown? (y/n): " INSTALL_DISCORD_STOP_ENABLE
			if [[ "$INSTALL_DISCORD_STOP_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_DISCORD_STOP="1"
			else
				INSTALL_DISCORD_STOP="0"
			fi
		echo ""
		read -p "Discord notifications for crashes? (y/n): " INSTALL_DISCORD_CRASH_ENABLE
			if [[ "$INSTALL_DISCORD_CRASH_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_DISCORD_CRASH="1"
			else
				INSTALL_DISCORD_CRASH="0"
			fi
		echo ""
		read -p "Discord notifications for tmpfs partition being close to full? (y/n): " INSTALL_DISCORD_TMPFS_SPACE_ENABLE
			if [[ "$INSTALL_DISCORD_TMPFS_SPACE_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_DISCORD_TMPFS_SPACE="1"
			else
				INSTALL_DISCORD_TMPFS_SPACE="0"
			fi
	elif [[ "$INSTALL_DISCORD_ENABLE" =~ ^([nN][oO]|[nN])$ ]]; then
		INSTALL_DISCORD_UPDATE="0"
		INSTALL_DISCORD_START="0"
		INSTALL_DISCORD_STOP="0"
		INSTALL_DISCORD_CRASH="0"
		INSTALL_DISCORD_TMPFS_SPACE="0"
	fi

	echo "Writing configuration file..."
	touch $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo 'discord_update='"$INSTALL_DISCORD_UPDATE" > $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo 'discord_start='"$INSTALL_DISCORD_START" >> $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo 'discord_stop='"$INSTALL_DISCORD_STOP" >> $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo 'discord_crash='"$INSTALL_DISCORD_CRASH" >> $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo 'discord_tmpfs_space='"$INSTALL_DISCORD_TMPFS_SPACE" >> $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo 'discord_color_prestart=16776960' >> $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo 'discord_color_poststart=65280' >> $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo 'discord_color_prestop=16776960' >> $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo 'discord_color_poststop=65280' >> $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo 'discord_color_update=47083' >> $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo 'discord_color_crash=16711680' >> $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo 'discord_color_tmpfs_space=16711680' >> $CONFIG_DIR/$SERVICE_NAME-discord.conf
	echo "$INSTALL_DISCORD_WEBHOOK" > $CONFIG_DIR/discord_webhooks.txt
	echo "Done"
}

#--------------------------

#Configures email integration
script_config_email() {
	echo ""
	read -p "Enable email notifications (y/n): " INSTALL_EMAIL_ENABLE
	if [[ "$INSTALL_EMAIL_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		echo ""
		read -p "Enter the email that will send the notifications (example: sender@gmail.com): " INSTALL_EMAIL_SENDER
		echo ""
		read -p "Enter the email that will recieve the notifications (example: recipient@gmail.com): " INSTALL_EMAIL_RECIPIENT
		echo ""
		read -p "Email notifications for game updates? (y/n): " INSTALL_EMAIL_UPDATE_ENABLE
			if [[ "$INSTALL_EMAIL_UPDATE_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_EMAIL_UPDATE="1"
			else
				INSTALL_EMAIL_UPDATE="0"
			fi
		echo ""
		read -p "Email notifications for server startup? (WARNING: this can be anoying) (y/n): " INSTALL_EMAIL_START_ENABLE
			if [[ "$INSTALL_EMAIL_START_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_EMAIL_START="1"
			else
				INSTALL_EMAIL_START="0"
			fi
		echo ""
		read -p "Email notifications for server shutdown? (WARNING: this can be anoying) (y/n): " INSTALL_EMAIL_STOP_ENABLE
			if [[ "$INSTALL_EMAIL_STOP_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_EMAIL_STOP="1"
			else
				INSTALL_EMAIL_STOP="0"
			fi
		echo ""
		read -p "Email notifications for crashes? (y/n): " INSTALL_EMAIL_CRASH_ENABLE
			if [[ "$INSTALL_EMAIL_CRASH_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_EMAIL_CRASH="1"
			else
				INSTALL_EMAIL_CRASH="0"
			fi
		echo ""
		read -p "Email notifications for tmpfs partition being close to full? (y/n): " INSTALL_EMAIL_TMPFS_SPACE_ENABLE
			if [[ "$INSTALL_EMAIL_TMPFS_SPACE_ENABLE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				INSTALL_EMAIL_TMPFS_SPACE="1"
			else
				INSTALL_EMAIL_TMPFS_SPACE="0"
			fi
		if [[ "$EUID" == "$(id -u root)" ]]; then
			read -p "Configure postfix? (y/n): " INSTALL_EMAIL_CONFIGURE
			if [[ "$INSTALL_EMAIL_CONFIGURE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
				echo ""
				read -p "Enter the relay host (example: smtp.gmail.com): " INSTALL_EMAIL_RELAY_HOST
				echo ""
				read -p "Enter the relay host port (example: 587): " INSTALL_EMAIL_RELAY_PORT
				echo ""
				read -p "Enter your password for $INSTALL_EMAIL_SENDER : " INSTALL_EMAIL_SENDER_PSW

				cat >> /etc/postfix/main.cf <<- EOF
				relayhost = [$INSTALL_EMAIL_RELAY_HOST]:$INSTALL_EMAIL_RELAY_PORT
				smtp_sasl_auth_enable = yes
				smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
				smtp_sasl_security_options = noanonymous
				smtp_tls_CApath = /etc/ssl/certs
				smtpd_tls_CApath = /etc/ssl/certs
				smtp_use_tls = yes
				EOF

				cat > /etc/postfix/sasl_passwd <<- EOF
				[$INSTALL_EMAIL_RELAY_HOST]:$INSTALL_EMAIL_RELAY_PORT    $INSTALL_EMAIL_SENDER:$INSTALL_EMAIL_SENDER_PSW
				EOF

				sudo chmod 400 /etc/postfix/sasl_passwd
				sudo postmap /etc/postfix/sasl_passwd
				sudo systemctl enable --now postfix
			fi
		else
			echo "Add the following lines to /etc/postfix/main.cf"
			echo "relayhost = [$INSTALL_EMAIL_RELAY_HOST]:$INSTALL_EMAIL_RELAY_HOST_PORT"
			echo "smtp_sasl_auth_enable = yes"
			echo "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd"
			echo "smtp_sasl_security_options = noanonymous"
			echo "smtp_tls_CApath = /etc/ssl/certs"
			echo "smtpd_tls_CApath = /etc/ssl/certs"
			echo "smtp_use_tls = yes"
			echo ""
			echo "Add the following line to /etc/postfix/sasl_passwd"
			echo "[$INSTALL_EMAIL_RELAY_HOST]:$INSTALL_EMAIL_RELAY_HOST_PORT    $INSTALL_EMAIL_SENDER:$INSTALL_EMAIL_SENDER_PSW"
			echo ""
			echo "Execute the following commands:"
			echo "sudo chmod 400 /etc/postfix/sasl_passwd"
			echo "sudo postmap /etc/postfix/sasl_passwd"
			echo "sudo systemctl enable postfix"
		fi
	elif [[ "$INSTALL_EMAIL_ENABLE" =~ ^([nN][oO]|[nN])$ ]]; then
		INSTALL_EMAIL_SENDER="none"
		INSTALL_EMAIL_RECIPIENT="none"
		INSTALL_EMAIL_UPDATE="0"
		INSTALL_EMAIL_START="0"
		INSTALL_EMAIL_STOP="0"
		INSTALL_EMAIL_CRASH="0"
		INSTALL_EMAIL_TMPFS_SPACE="0"
	fi

	echo "Writing configuration file..."
	echo 'email_sender='"$INSTALL_EMAIL_SENDER" > $CONFIG_DIR/$SERVICE_NAME-email.conf
	echo 'email_recipient='"$INSTALL_EMAIL_RECIPIENT" >> $CONFIG_DIR/$SERVICE_NAME-email.conf
	echo 'email_update='"$INSTALL_EMAIL_UPDATE" >> $CONFIG_DIR/$SERVICE_NAME-email.conf
	echo 'email_start='"$INSTALL_EMAIL_START" >> $CONFIG_DIR/$SERVICE_NAME-email.conf
	echo 'email_stop='"$INSTALL_EMAIL_STOP" >> $CONFIG_DIR/$SERVICE_NAME-email.conf
	echo 'email_crash='"$INSTALL_EMAIL_CRASH" >> $CONFIG_DIR/$SERVICE_NAME-email.conf
	echo 'email_tmpfs_space='"$INSTALL_EMAIL_TMPFS_SPACE" >> $CONFIG_DIR/$SERVICE_NAME-email.conf
	chown $SERVICE_NAME:$SERVICE_NAME $CONFIG_DIR/$SERVICE_NAME-email.conf
	echo "Done"
}

#--------------------------

#Configures tmpfs integration
script_config_tmpfs() {
	echo ""
	read -p "Install tmpfs? (y/n): " INSTALL_TMPFS
	echo ""
	if [[ "$INSTALL_TMPFS" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		read -p "Ramdisk size (I recommend at least 8GB): " INSTALL_TMPFS_SIZE
		echo "Installing ramdisk configuration"
		if [[ "$EUID" == "$(id -u root)" ]] ; then
			cat >> /etc/fstab <<- EOF

			# /mnt/tmpfs
			tmpfs				   $TMPFS_DIR		tmpfs		   rw,size=$INSTALL_TMPFS_SIZE,uid=$(id -u $SERVICE_NAME),mode=0777	0 0
			EOF
		else
			echo "Add the following line to /etc/fstab:"
			echo "tmpfs				   $TMPFS_DIR		tmpfs		   rw,size=$INSTALL_TMPFS_SIZE,uid=$(id -u $SERVICE_NAME),mode=0777	0 0"
		fi
	fi
}

#--------------------------

#Configures the script
script_config_script() {
	echo -e "${CYAN}Script configuration${NC}"
	echo -e ""
	echo -e "The script uses steamcmd to download the dedicated server, however you have the option to manualy copy the files yourself."
	echo -e ""
	echo -e "The script can work either way. The $SERVICE_NAME user's home directory is located in /srv/$SERVICE_NAME and all files are located there."
	echo -e "This configuration installation will only install the essential configuration. No discord, email or tmpfs/ramdisk"
	echo -e "Default configuration will be applied and it can work without it. You can run the optional configuration for each using the"
	echo -e "following arguments with the script:"
	echo -e ""
	echo -e "${GREEN}config_discord ${RED}- ${GREEN}Configures discord integration.${NC}"
	echo -e "${GREEN}config_email   ${RED}- ${GREEN}Configures email integration. Due to postfix configuration files being in /etc this has to be executed as root.${NC}"
	echo -e "${GREEN}config_tmpfs   ${RED}- ${GREEN}Configures tmpfs/ramdisk. Due to it adding a line to /etc/fstab this has to be executed as root.${NC}"
	echo -e ""
	echo -e ""
	read -p "Press any key to continue" -n 1 -s -r
	echo ""

	echo "Enabling services"
	systemctl --user enable --now $SERVICE_NAME-timer-1.timer
	systemctl --user enable --now $SERVICE_NAME-timer-2.timer

	echo "Adding first server"
	script_add_server

	echo "Writing config files"

	touch $CONFIG_DIR/$SERVICE_NAME-script.conf
	echo 'script_bckp_delold=7' > $CONFIG_DIR/$SERVICE_NAME-script.conf
	echo 'script_log_delold=7' >> $CONFIG_DIR/$SERVICE_NAME-script.conf
	echo 'script_log_game_delold=7' >> $CONFIG_DIR/$SERVICE_NAME-script.conf
	echo 'script_update_game='"$INSTAL_GAME_SERVER_UPDATES" >> $CONFIG_DIR/$SERVICE_NAME-script.conf
	echo 'script_update_ignore_failed_startups=0' >> $CONFIG_DIR/$SERVICE_NAME-script.conf
	echo 'script_timeout_save=120' >> $CONFIG_DIR/$SERVICE_NAME-script.conf
	echo 'script_tmpfs_space=90' >> $CONFIG_DIR/$SERVICE_NAME-script.conf

	echo "Configuration complete"
	echo "For any settings you'll want to change, edit the files located in $CONFIG_DIR/"
	echo "To enable additional fuctions like discord, email and tmpfs execute the script with the help argument."
}

#--------------------------

#Do not allow for another instance of this script to run to prevent data loss
if [[ "pre-start" != "$1" ]] && [[ "post-start" != "$1" ]] && [[ "pre-stop" != "$1" ]] && [[ "peri-stop" != "$1" ]] && [[ "post-stop" != "$1" ]] && [[ "send_notification_crash" != "$1" ]] && [[ "server_tmux_install" != "$1" ]] && [[ "attach" != "$1" ]] && [[ "status" != "$1" ]]; then
	SCRIPT_PID_CHECK=$(basename -- "$0")
	if pidof -x "$SCRIPT_PID_CHECK" -o $$ > /dev/null; then
		echo "An another instance of this script is already running, please clear all the sessions of this script before starting a new session"
		exit 2
	fi
fi

#--------------------------

#Check what user is executing the script and allow root to execute certain functions.
if [[ "$EUID" != "$(id -u $SERVICE_NAME)" ]] && [[ "config_email" != "$1" ]] && [[ "config_tmpfs" != "$1" ]]; then
	echo "This script is only able to be executed by the $SERVICE_NAME user."
	echo "The following functions can also be executed as root: config_email, config_tmpfs"
	exit 3
fi

#--------------------------

#Script help page
case "$1" in
	help)
		echo -e "${CYAN}Time: $(date +"%Y-%m-%d %H:%M:%S") ${NC}"
		echo -e "${CYAN}$NAME server script by 7thCore${NC}"
		echo "Version: $VERSION"
		echo ""
		echo "Basic script commands:"
		echo -e "${GREEN}diag   ${RED}- ${GREEN}Prints out package versions and if script files are installed.${NC}"
		echo -e "${GREEN}status ${RED}- ${GREEN}Display status of server.${NC}"
		echo ""
		echo "Configuration and installation:"
		echo -e "${GREEN}config_script  ${RED}- ${GREEN}Configures the script, enables the systemd services and installs the wine prefix.${NC}"
		echo -e "${GREEN}config_discord ${RED}- ${GREEN}Configures discord integration.${NC}"
		echo -e "${GREEN}config_email   ${RED}- ${GREEN}Configures email integration. Due to postfix configuration files being in /etc this has to be executed as root.${NC}"
		echo -e "${GREEN}config_tmpfs   ${RED}- ${GREEN}Configures tmpfs/ramdisk. Due to it adding a line to /etc/fstab this has to be executed as root.${NC}"
		echo ""
		echo "Server services managment:"
		echo -e "${GREEN}add_server                   ${RED}- ${GREEN}Adds a server instance.${NC}"
		echo -e "${GREEN}remove_server                ${RED}- ${GREEN}Removes a server instance.${NC}"
		echo -e "${GREEN}enable_services              ${RED}- ${GREEN}Enables all services dependant on the configuration file of the script.${NC}"
		echo -e "${GREEN}disable_services             ${RED}- ${GREEN}Disables all services. The server and the script will not start up on boot anymore.${NC}"
		echo -e "${GREEN}reload_services              ${RED}- ${GREEN}Reloads all services, dependant on the configuration file.${NC}"
		echo ""
		echo "Server and console managment:"
		echo -e "${GREEN}start <server number>        ${RED}- ${GREEN}Start the server. If the server number is not specified the function will start all servers.${NC}"
		echo -e "${GREEN}stop <server number>         ${RED}- ${GREEN}Stop the server. If the server number is not specified the function will stop all servers.${NC}"
		echo -e "${GREEN}restart <server number>      ${RED}- ${GREEN}Restart the server. If the server number is not specified the function will restart all servers.${NC}"
		echo -e "${GREEN}sync                         ${RED}- ${GREEN}Sync from tmpfs to hdd/ssd for all active server running on tmpfs.${NC}"
		echo -e "${GREEN}attach <server number>       ${RED}- ${GREEN}Attaches to the tmux session of the specified server.${NC}"
		echo ""
		echo "Backup managment:"
		echo -e "${GREEN}backup                       ${RED}- ${GREEN}Backup files if server running.${NC}"
		echo ""
		echo "Steam managment:"
		echo -e "${GREEN}update                       ${RED}- ${GREEN}Update the server, if the server is running it will save it, shut it down, update it and restart it.${NC}"
		echo -e "${GREEN}verify <server number>       ${RED}- ${GREEN}Verifiy game server files, if the server is running it will save it, shut it down, verify it and restart it.${NC}"
		echo ""
		;;
#--------------------------
#Basic script functions
	diag)
		script_diagnostics
		;;
	status)
		script_status
		;;
#--------------------------
#Configuration and installation
	config_script)
		script_config_script
		;;
	config_discord)
		script_config_discord
		;;
	config_email)
		script_config_email
		;;
	config_tmpfs)
		script_config_tmpfs
		;;
#--------------------------
#Server services managment
	add_server)
		script_add_server
		;;
	remove_server)
		script_remove_server
		;;
	enable_services)
		script_enable_services_manual
		;;
	disable_services)
		script_disable_services_manual
		;;
	reload_services)
		script_reload_services
		;;
#--------------------------
#Server and console managment
	start)
		script_start $2
		;;
	stop)
		script_stop $2
		;;
	restart)
		script_restart $2
		;;
	sync)
		script_sync
		;;
	attach)
		script_attach $2
		;;
#--------------------------
#Backup managment
	backup)
		script_backup
		;;
#--------------------------
#Steam managment
	update)
		script_update
		;;
	verify)
		script_verify_game_integrity
		;;
#--------------------------
#Hidden functions meant for systemd service use
	pre-start)
		script_prestart $2 $3
		;;
	post-start)
		script_poststart $2
		;;
	peri-stop)
		script_peristop $2
		;;
	pre-stop)
		script_prestop $2
		;;
	post-stop)
		script_poststop $2 $3
		;;
	send_notification_crash)
		script_send_notification_crash $2
		;;
	server_tmux_install)
		script_server_tmux_install $2 $3
		;;
	timer_one)
		script_timer_one
		;;
	timer_two)
		script_timer_two
		;;
	*)
#--------------------------
#General output if the script does not recognise the argument provided
	echo -e "${CYAN}Time: $(date +"%Y-%m-%d %H:%M:%S") ${NC}"
	echo -e "${CYAN}$NAME server script by 7thCore${NC}"
	echo ""
	echo "For more detailed information, execute the script with the -help argument"
	echo ""
	echo -e "${GREEN}Basic script commands${RED}: ${GREEN}help, diag, status${NC}"
	echo -e "${GREEN}Configuration and installation${RED}: ${GREEN}config_script, config_discord, config_email, config_tmpfs${NC}"
	echo -e "${GREEN}Server services managment${RED}: ${GREEN}add_server, remove_server, enable_services, disable_services, reload_services${NC}"
	echo -e "${GREEN}Server and console managment${RED}: ${GREEN}start, start_no_err, stop,restart, sync, attach${NC}"
	echo -e "${GREEN}Backup managment${RED}: ${GREEN}backup${NC}"
	echo -e "${GREEN}Steam managment${RED}: ${GREEN}update, verify${NC}"
	exit 1
	;;
esac

exit 0
