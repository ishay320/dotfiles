#!/bin/bash

# set -x
FILE=$1

if [[ "${FILE}" == "-h" ]]; then
	echo "Usage: $0 <optinal files.csv>"
	exit 0
fi

if [[ -z "${FILE}" ]]; then
	FILE=./files.csv
fi

COLOR_OFF='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'
function log_info() {
	echo -e "${GREEN}[INFO] $*${COLOR_OFF}"
}
function log_error() {
	echo -e "${RED}[ERROR] $*${COLOR_OFF}"
}

directory_create() {
	local directory="$1"
	if [[ ! -d "${directory}" ]]; then
		log_info "creating directory: '${directory}'"
		mkdir -p "${directory}"
	fi
}

link_file() {
	local src=$1
	eval local dest="$2"
	local root=$3
	directory_create "${dest}"
	if [[ $root -eq 1 ]]; then
		log_info "linking the file with sudo: '${src}' to '${dest}'"
		sudo ln -s -f "$(pwd)/$src" "${dest}"
	else
		log_info "linking the file: '${src}' to '${dest}'"
		ln -s -f "$(pwd)/$src" "${dest}"
	fi
}

copy_file() {
	local src=$1
	eval local dest="$2"
	local root=$3
	directory_create "${dest}"
	if [[ $root -eq 1 ]]; then
		log_info "copying the file with sudo: '${src}' to '${dest}'"
		sudo cp -r "${src}" "${dest}"
	else
		log_info "copying the file: '${src}' to '${dest}'"
		cp -r "${src}" "${dest}"
	fi
}

{
	line_num=1
	read -r # jump over first line
	while IFS=, read -r action src dest rest; do
		root=0
		if [[ "$action" == "!"* ]]; then
			action="${action:1}"
			root=1
		fi
		if [[ "$src" == "./"* ]]; then
			src="${src:2}"
		fi
		if [[ $action == "copy" ]]; then
			copy_file "$src" "$dest" $root
		elif [[ $action == "link" ]]; then
			link_file "$src" "$dest" $root
		else
			log_error "unknown action: '$action' at line $line_num: '$action,$src,$dest'"
			exit 1
		fi
		((line_num++))
	done
} <"${FILE}"

read -p "Do you want to update nvim config? (y/N) " update_nvim
if [[ "$update_nvim" == "y" ]]; then
	log_info "pulling all submodels"
	git submodule update --init

	log_info "moving nvim to master"
	cd ./nvim || exit
	git checkout master
	git pull
	cd ..
fi
