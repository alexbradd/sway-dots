#!/bin/bash
# shellcheck disable=2068

set -u

MYNAME="heapscript.sh"
VERSION=0.1.0

INVALID_CMD_FMT="Invalid argument '%s' for %s\n"

# Handles dock command
function dock() {
	case $1 in
	enable)
		swaymsg 'bindswitch --no-warn --locked lid:on  output eDP-1 disable' &&
			swaymsg 'bindswitch --no-warn --locked lid:off output eDP-1 enable' &&
			notify-send 'System' 'Docking mode enabled'
		return $?
		;;
	disable)
		swaymsg 'bindswitch --no-warn --locked lid:on exec systemctl suspend' &&
			swaymsg 'unbindswitch --locked lid:off' &&
			notify-send 'System' 'Docking mode disabled'
		return $?
		;;
	*)
		printf "$INVALID_CMD_FMT" "$1" "dock" >&2
		return 1
		;;
	esac
}

# Handles notification command
function notifications() {
	case $1 in
	enable)
		case $2 in
		multidisplay)
			makoctl mode -r nomultidisplay &&
				notify-send "System" "Notifications visible on all outputs"
			return $?
			;;
		dnd)
			makoctl mode -a dnd &&
				notify-send "System" "Notifications disabled"
			return $?
			;;
		*)
			printf "$INVALID_CMD_FMT" "$1" 'notifications enable' >&2
			return 1
			;;
		esac
		;;
	disable)
		case $2 in
		multidisplay)
			makoctl mode -r nomultidisplay &&
				notify-send "System" "Notifications visible on all outputs"
			return $?
			;;
		dnd)
			makoctl mode -r dnd &&
				notify-send "System" "Notifications enable"
			return $?
			;;
		*)
			printf "$INVALID_CMD_FMT" "$1" 'notifications disable' >&2
			return 1
			;;
		esac
		;;
	*)
		printf "$INVALID_CMD_FMT" "$1" 'notifications' >&2
		return 1
		;;
	esac
}

# Handles edp command
function edp() {
	case $1 in
	high-refresh-rate)
		swaymsg 'output eDP-1 mode 2560x1440@165.003Hz' &&
			notify-send "System" "High refresh rate enabled"
		return $?
		;;
	low-refresh-rate)
		swaymsg 'output eDP-1 mode 2560x1440@40.002Hz' &&
			notify-send "System" "Low refresh rate enabled"
		return $?
		;;
	*)
		printf "$INVALID_CMD_FMT" "$1" 'edp' >&2
		return 1
		;;
	esac
}

# Parse the positional arguments passed as argument and execute the corresponding
# actions
function doCommand() {
	case $1 in
	dock)
		shift
		dock $@
		return $?
		;;
	notifications)
		shift
		notifications $@
		return $?
		;;
	edp)
		shift
		edp $@
		return $?
		;;
	*)
		printf "Invalid command\n" >&2
		return 1
		;;
	esac
}

# Parse arguments and execute logic
function main() {
	local opts
	opts=$(getopt -n "$MYNAME" \
		-o hv \
		--long help,version -- $@)
	[ "$?" -ne 0 ] && return 1

	eval set -- "$opts"
	while true; do
		case "$1" in
		-h | --help)
			cat <<EOF
Usage: $MYNAME [options]... COMMAND

Groups a heap of scripts into a single, hopefully less crappy, one.

Options:
  -h  --help     Show this message
  -v, --version  Print the version

Commands:
  edp low-refresh-rate|high-refresh-rate  Enable high/low refresh rate for the
                                          internal display
  notifications enable|disable <mode>     Enable/disable notification mode, supported
                                          modes are: 'nomultidisplay', 'nofullscreen' and 'dnd'
  dock enable|disable                     Enables/disables clamshell mode
EOF
			return 0
			;;
		-v | --version)
			printf "v%s\n" "$VERSION"
			return 0
			;;
		--)
			shift
			break
			;;
		esac
	done

	doCommand $@
	return $?
}

main $@
exit $?

