#!/bin/bash

#!/usr/bin/env bash

#colors
#bold="(tput bold)"
magenta="\033[1;35m"
green="\033[1;32m"
white="\033[1;37m"
blue="\033[1;34m"
red="\033[1;31m"
black="\033[1;40;30m"
yellow="\033[1;33m"
cyan="\033[1;36m"
reset="\033[0m"
bgyellow="\033[1;43;33m"
bgwhite="\033[1;47;37m"
c0=${reset}
c1=${magenta}
c2=${green}
c3=${white}
c4=${blue}
c5=${red}
c6=${yellow}
c7=${cyan}
c8=${black}
c9=${bgyellow}
c10=${bgwhite}
# Get package installed
get_package_info() {
	pkg_count=$(get_pkg_count)


	if [ "$pkg_count" -ne 0 ]; then
		echo -n "$pkg_count"

		else
		echo "Unknown"
	fi
}
# Get uptime
get_uptime() {
	if [ "$kernel" = "Darwin" ]; then
		up=$(uptime | awk 'NR==1{print $3}')
		echo " ${up::-1}"
	else
		uptime -p | sed 's/up//'
	fi
}
# Get the init
get_init() {
	if [ "$kernel" = "Android" ]; then
		echo 'init.rc'
	elif [ "$kernel" = "Darwin" ]; then
		echo 'launchd'
	elif pidof -q systemd; then
		echo 'systemd'
	elif [ -f '/sbin/openrc' ]; then
		echo 'openrc'
	elif [ -f '/sbin/dinit' ]; then
		echo 'dinit'
	else
		cut -d ' ' -f 1 /proc/1/comm
	fi
}
# Get Memory usage
get_mem() {
	if [ "$kernel" = "Darwin" ]; then
		total_mem=$(($(sysctl -a | awk '/hw./' | awk '/mem/' | awk 'NR==1{print $2}') / 2**20 ))
		used_mem=$(vm_stat | grep -E "Pageouts:" | awk 'NR==1{print $2}')
		echo "${used_mem::-1} MB / $total_mem MB"
	else
		free --mega | awk 'NR == 2 { print $3" / "$2" MB" }'
	fi
}
# Get count of packages installed
get_pkg_count() {
	package_managers=('xbps-install' 'apk' 'port' 'apt' 'pacman' 'nix' 'dnf' 'rpm' 'emerge' 'eopkg')
	for package_manager in "${package_managers[@]}"; do
		if command -v "$package_manager" 2>/dev/null >&2; then
			case "$package_manager" in
			xbps-install) xbps-query -l | wc -l ;;
			apk) apk search | wc -l ;;
			apt) if [ "$kernel" != "Darwin" ]; then
					echo $(($(apt list --installed 2>/dev/null | wc -l) - 1))
				 else
					echo 0
				 fi
				 ;;
			pacman) pacman -Q | wc -l ;;
			nix) nix-env -qa --installed '*' | wc -l ;;
			dnf) dnf list installed | wc -l ;;
			rpm) rpm -qa | wc -l ;;
			emerge) qlist -I | wc -l ;;
			port) port installed 2>/dev/null | wc -l | awk 'NR==1{print $1}' ;;
			eopkg) eopkg li | wc -l ;;
			esac

			# if a package manager is found return from the function
			return
		fi
	done
	echo 0
}


echo -e "\n"
echo -e "                \e[1;31m Installed Kernel\e[m                     $(uname -r)"
echo -e "   		\e[1;32m Host Name\e[m                            $(uname -n)"
echo -e "   		\e[1;33m OS Name\e[m                              $(lsb_release -d | cut -f 2)"
echo -e "      ${c8}${c0}${c9}oo${c0}${c8}|${c0} 	\e[1;35m Window Manager\e[m                      $(wmctrl -m | grep -i name | cut -f 2 -d ":")"
echo -e "     ${c8}/${c0}${c10} ${c0}${c8}'\'${c0}     	\e[1;34m Number of Packages\e[m                   $(get_package_info)"
echo -e "    ${c9}(${c0}${c8}\_;/${c0}${c9})${c0} 	\e[1;35m init System\e[m                          $(get_init)"
echo -e "      	        \e[1;36m sh system\e[m                            ${SHELL##*/}"
echo -e "    ${c9}V${c0}${c8}S${c0}${c5}Fetch${c0}     \e[1;37m Ram Used\e[m                             $(get_mem)"
echo -e "           	\e[1;33m CPU\e[m                                 $(cat /proc/cpuinfo | grep model\ name | cut -f 2 -d ":" | sort -u)"
echo -e "           	\e[1;32m System Uptime\e[m                       $(get_uptime)"
echo -e "\n\n"
