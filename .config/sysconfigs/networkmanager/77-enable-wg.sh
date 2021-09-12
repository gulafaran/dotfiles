#!/bin/bash

interface=$1 status=$2

if { [ "${interface}" == "wlp5s0" ] ||  [ "${interface}" == "enp4s0" ]; }  && [ "${CONNECTION_UUID}" != "xxxx" ]; then
	case $status in
		up)
			#wg-quick up vpn
			nmcli connection up "WireGuard Bahnhof"
		;;
		down)
			nmcli connection down "WireGuard Bahnhof"
		;;
	esac
fi
