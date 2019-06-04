#!/bin/bash
set -e
#some vars
export MOODLE_DOCKER_WWWROOT=./moodle
export MOODLE_VERSION=3.2
export MOODLE_DOCKER_DB=mariadb
export MOODLE_DOCKER_PHP_VERSION=7.1
export MOODLE_DOCKER_WEB_HOST=2f80a06c.ngrok.io
#localhost
#ac8c4419.ngrok.io
export MOODLE_DOCKER_WEB_PORT=80
export ASSETDIR=./assets

function all() {
	kill_containers
	build
	run
}
function clean() {
	echo "[-] THIS WILL REMOVE THE PREVIOUS MOODLE INSTALLATION!(if present)"
	read -p "Are you sure? [yN]" -n 1 -r
	echo # (optional) move to a new line
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		echo "Quitting..."
		[[ "$0" == "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
	fi
	if [ -f "./tmp.zip" ]; then
		rm ./tmp.zip
	fi
	if [ -d "./moodle" ]; then
		rm -rf ./moodle
	fi
	if [ -d "./assets" ]; then
		rm -rf ./assets
	fi
	docker-compose -f base-moodle.yml rm webserver db
}
function build() {
	clean
	echo "[+] Downloading Moodle VERSION $MOODLE_VERSION"
	wget -O- -O ./tmp.zip https://downloads.sourceforge.net/project/moodle/Moodle/stable32/moodle-$MOODLE_VERSION.zip
	if [! -f "./tmp.zip" ]; then
		echo "Problems downloading the moodle"
	fi
	unzip ./tmp.zip -d ./
	rm ./tmp.zip
	mkdir ./assets
	cp ./config.docker-template.php $MOODLE_DOCKER_WWWROOT/config.php
}
function exec_statement() {
	dockercompose="docker-compose -f ./base-moodle.yml"
	# Mac OS Compatbility
	if [[ "$(uname)" == "Darwin" ]]; then
		# Support https://docs.docker.com/docker-for-mac/osxfs-caching/
		dockercompose="${dockercompose} -f ./volumes-cached.yml"
	fi
	$dockercompose $1
}
function run(){
	exec_statement up
}
function kill_containers() {
	exec_statement kill
	# docker stop $(docker ps -q)
	# docker rm $(docker ps -a -q)
	# docker rmi $(docker images -q)
	# docker system prune
}
while test $# -gt 0; do
	echo "[*] Options: clean, build, run, kill or all"
	case $1 in
	all)
		all
		;;
	clean)
		clean
		;;
	build)
		build
		;;
	run)
		run
		;;
	kill)
		kill_containers
		;;
	*) echo "Not an option!" ;;
	esac
	break
done