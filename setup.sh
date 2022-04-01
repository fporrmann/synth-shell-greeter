#!/bin/bash

##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  | Copyright (c) 2019-2021, Andres Gongora <mail@andresgongora.com>.     |
##  |                                                                       |
##  | This program is free software: you can redistribute it and/or modify  |
##  | it under the terms of the GNU General Public License as published by  |
##  | the Free Software Foundation, either version 3 of the License, or     |
##  | (at your option) any later version.                                   |
##  |                                                                       |
##  | This program is distributed in the hope that it will be useful,       |
##  | but WITHOUT ANY WARRANTY; without even the implied warranty of        |
##  | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
##  | GNU General Public License for more details.                          |
##  |                                                                       |
##  | You should have received a copy of the GNU General Public License     |
##  | along with this program. If not, see <http://www.gnu.org/licenses/>.  |
##  |                                                                       |
##  +-----------------------------------------------------------------------+

##
##	QUICK INSTALLER
##




##==============================================================================
##	INCLUDE DEPENDENCIES
##==============================================================================
[ "$(type -t include)" != 'function' ]&&{ include(){ { [ -z "$_IR" ]&&_IR="$PWD"&&cd $(dirname "${BASH_SOURCE[0]}")&&include "$1"&&cd "$_IR"&&unset _IR;}||{ local d=$PWD&&cd "$(dirname "$PWD/$1")"&&. "$(basename "$1")"&&cd "$d";}||{ echo "Include failed $PWD->$1"&&exit 1;};};}
include 'bash-tools/bash-tools/user_io.sh'
include 'bash-tools/bash-tools/hook_script.sh'
include 'bash-tools/bash-tools/assemble_script.sh'






##==============================================================================
##	SELECT SETUP LOCATION (PROMPT USER IF NEED BE)
##==============================================================================

## SWITCH BETWEEN AUTOMATIC AND USER INSTALLATION
if [ "$#" -eq 0 ]; then
	OUTPUT_SCRIPT="$HOME/.config/synth-shell/synth-shell-greeter.sh"
	OUTPUT_CONFIG_DIR="$HOME/.config/synth-shell"
	USER_CHOICE=""

elif [ "$#" -eq 2 ]; then
	OUTPUT_SCRIPT="$1"
	OUTPUT_CONFIG_DIR="$2"
	USER_CHOICE="y"

else
	printError "Wrong number of arguments passed to setup script"
	exit 1
fi

## CREATE HOOK
printInfo "Installing script as $OUTPUT_SCRIPT"
if [ -z "$USER_CHOICE" ]; then
	USER_CHOICE=$(promptUser "Add hook your .bashrc file or equivalent?\n\tRequired for autostart on new terminals" "[Y]/[n]?" "yYnN" "y")
fi
case "$USER_CHOICE" in
	""|y|Y )	hookScript $OUTPUT_SCRIPT ;;
	n|N )		;;
	*)		printError "Invalid option"; exit 1
esac






##==============================================================================
##	EMPLACE SCRIPT
##==============================================================================

## DEFINE LOCAL VARIABLES
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
INPUT_SCRIPT="$DIR/synth-shell-greeter/synth-shell-greeter.sh"
INPUT_CONFIG_DIR="$DIR/config"



## HEADER TO BE ADDED AT THE TOP OF THE ASSEMBLED SCRIPT
OUTPUT_SCRIPT_HEADER=$(printf '%s'\
	"##\n"\
	"##\n"\
	"##  =======================\n"\
	"##  WARNING!!\n"\
	"##  DO NOT EDIT THIS FILE!!\n"\
	"##  =======================\n"\
	"##\n"\
	"##  This file was generated by an installation script.\n"\
	"##  It might be overwritten without warning at any time\n"\
	"##  and you will lose all your changes.\n"\
	"##\n"\
	"##  Visit for instructions and more information:\n"\
	"##  https://github.com/andresgongora/synth-shell/\n"\
	"##\n"\
	"##\n\n\n")



## SETUP SCRIPT
assembleScript "$INPUT_SCRIPT" "$OUTPUT_SCRIPT" "$OUTPUT_SCRIPT_HEADER"






##==============================================================================
##	EMPLACE CONFIGURATION FILES
##==============================================================================

## SETUP CONFIGURATION FILES
[ -d "$OUTPUT_CONFIG_DIR" ] || mkdir -p "$OUTPUT_CONFIG_DIR"
cp -r "$INPUT_CONFIG_DIR/." "$OUTPUT_CONFIG_DIR/"


## SETUP DEFAULT SYNTH-SHELL-GREETER CONFIG FILE
## If file exists, store to .new instead
## Choose depending on distro, fallback to default
CONFIG_FILE="$OUTPUT_CONFIG_DIR/synth-shell-greeter.config"
if [ -f "$CONFIG_FILE" ]; then
	CONFIG_FILE="${CONFIG_FILE}.new"
fi
DISTRO=$(cat /etc/os-release | grep "ID=" | sed 's/ID=//g' | head -n 1)
case "$DISTRO" in
	'arch' )	cp "$INPUT_CONFIG_DIR/os/synth-shell-greeter.archlinux.config" "$CONFIG_FILE" ;;
	'manjaro' )	cp "$INPUT_CONFIG_DIR/os/synth-shell-greeter.manjaro.config" "$CONFIG_FILE" ;;
	'ubuntu' )	cp "$INPUT_CONFIG_DIR/os/synth-shell-greeter.ubuntu.config" "$CONFIG_FILE" ;;
	'debian' )	cp "$INPUT_CONFIG_DIR/os/synth-shell-greeter.debian.config" "$CONFIG_FILE" ;;
	'raspbian' )	cp "$INPUT_CONFIG_DIR/os/synth-shell-greeter.raspbian.config" "$CONFIG_FILE" ;;
	*)		cp "$INPUT_CONFIG_DIR/synth-shell-greeter.config.default" "$CONFIG_FILE" ;;
esac

cp "$INPUT_CONFIG_DIR/synth-shell-greeter.config.default" "$CONFIG_FILE"
