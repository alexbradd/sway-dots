#!/bin/bash

set -u

DND_OFF=""
DND_ON=""

[ -z "$(pgrep mako)" ] && {
  printf '{"text": "?", "tooltip": "Notification daemon not running"}';
  exit
}

IS_DND_OFF="$(makoctl mode | grep -q 'dnd'; echo "$?")"
if [ $IS_DND_OFF -eq 1 ]; then
  printf '{"text": "%s", "tooltip": "DnD disabled"}' "$DND_OFF"
else
  printf '{"text": "%s", "tooltip": "DnD enabled"}' "$DND_ON"
fi
