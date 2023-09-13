#!/bin/bash
MYNAME="sway-input.sh"

format="%s"
dmenu_no_multiple_rows="-no-fixed-num-lines -lines 0"
dmenu="rofi -dmenu $dmenu_no_multiple_rows -theme theme-dmenu"
swaymsg="swaymsg"

read_stdin=0

while [ $# -gt 0 ]
do
    case $1 in
        -h)
          cat <<EOF
Usage $MYNAME [options]..

Options:
  -h            Dispaly help
  -v            Display swaymsg version
  -s <socket>   Use socket for swaymsg
  -F <fmt_str>  Use following format string for command passed to swaymsg
  -P <str>      Use following prompt for dmenu
  -i            Tell dmenu to read stdin
  -l            Unsupported
EOF
          exit 0
          ;;
        -s)
            swaymsg="$swaymsg -s '$2'"
            shift
            ;;
        -F)
            format="$2"
            shift
            ;;
        -i)
            dmenu="${dmenu/$dmenu_no_multiple_rows/}"
            read_stdin=1
            ;;
        -P)
            dmenu="$dmenu -p '$2'"
            shift
            ;;
        -l)
            echo "Warning: -l is not supported"
            ;;
        -v)
            exec swaymsg -v
            ;;
        *)
            echo "Unknown argument '$1'" >&2
            exit 1
            ;;
    esac
    shift
done

if [ $read_stdin -eq 1 ]; then
  cmd=$(eval $dmenu < /dev/stdin)
else
  cmd=$(eval $dmenu < /dev/null)
fi
[ $? -ne 0 ] && exit $?

cmd=$(printf "$format" "$cmd")
eval $swaymsg "$cmd"
exit $?
