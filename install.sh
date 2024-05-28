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

link_file() {
	local src=$1
	eval local dest="$2"
	log_info "linking the file: '${src}' to '${dest}'"
	ln -s -f "$(pwd)/$src" "${dest}"
}

{
	read -r # jump over first line
	while IFS=, read -r src dest rest; do
		[[ "$src" == "#"* || "$src" == "" ]] && continue # jump on comments or empty lines

		link_file "$src" "$dest"
	done
} <"${FILE}"

log_info "pulling all submodels"
git submodule update --init

log_info "moving nvim to master"
cd ./nvim
git checkout master
git pull
cd ..
