#!/bin/bash
# LGSM command_backup.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Wipes server data, useful after updates for some games like Rust

local commandname="WIPE"
local commandaction="data wipe"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
fn_print_header
fn_script_log "Entering ${gamename} ${commandaction}"

# Process to server wipe
fn_wipe_server_process(){
	check_status.sh
	if [ "${status}" != "0" ]; then
		exitbypass=1
		command_stop.sh
		fn_wipe_server_remove_files
		exitbypass=1
		command_start.sh
	else
		fn_wipe_server_remove_files
	fi
	echo "server data wiped"
	fn_script_log "server data wiped."
}

# Provides an exit code upon error
fn_wipe_exit_code(){
	((exitcode=$?))
	if [ ${exitcode} -ne 0 ]; then
		fn_script_log_fatal "${currentaction}"
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
}

# Removes files to wipe server
fn_wipe_server_remove_files(){
	# Rust Wipe
	if [ "${gamename}" == "Rust" ]; then
		if [ -n "$(find "${serveridentitydir}" -type f -name "proceduralmap*.sav")" ]; then
			currentaction="Removing map ${serveridentitydir}/proceduralmap*.sav"
			echo -en "${currentaction}"
			fn_script_log "${currentaction}"
			rm -f "${serveridentitydir}/proceduralmap*.sav"
			fn_wipe_exit_code
		fi
		if [ -d "${serveridentitydir}/user" ]; then
			currentaction="Removing user ${serveridentitydir}/user"
			echo -en "${currentaction}"
			fn_script_log "${currentaction}"
			rm -rf "${serveridentitydir}/user"
			fn_wipe_exit_code
		fi
		if [ -d "${serveridentitydir}/storage" ]; then
			currentaction="Removing storage ${serveridentitydir}/storage"
			echo -en "${currentaction}"
			fn_script_log "${currentaction}"
			rm -rf "${serveridentitydir}/storage"
			fn_wipe_exit_code
		fi
		if [ -d "$(find "${serveridentitydir}" -type f -name "Log.*.txt")" ]; then
			currentaction="Removing storage ${serveridentitydir}/Log.*.txt"
			echo -en "${currentaction}"
			fn_script_log "${currentaction}"
			rm -f "${serveridentitydir}/Log.*.txt"
			fn_wipe_exit_code
		fi
	# You can add an "elif" here to add another game or engine
	fi
}

# Check if there is something to wipe, prompt the user, and call appropriate functions
# Rust Wipe
if [ "${gamename}" == "Rust" ]; then
	if [ -d "${serveridentitydir}/storage" ]||[ -d "${serveridentitydir}/user" ]||[ -n "$(find "${serveridentitydir}" -type f -name "proceduralmap*.sav")" ]||[ -n "$(find "${serveridentitydir}" -type f -name "Log.*.txt")" ]; then
		fn_print_warning_nl "Any user, storage, log and map data from ${serveridentitydir} will be erased."
		while true; do
			read -e -i "y" -p "Continue? [Y/n]" yn
			case $yn in
			[Yy]* ) break;;
			[Nn]* ) echo Exiting; core_exit.sh;;
			* ) echo "Please answer yes or no.";;
			esac
		done
		fn_script_log_info "User selects to erase any user, storage, log and map data from ${serveridentitydir}"
		fn_wipe_server_process
	else 
		fn_print_information "No data to wipe was found"
		fn_script_log_info "No data to wipe was found."
		core_exit.sh
	fi
# You can add an "elif" here to add another game or engine
else
	# Game not listed
	fn_print_information "Wipe is not available for this game"
	fn_script_log_info "Wipe is not available for this game."
	core_exit.sh
fi
