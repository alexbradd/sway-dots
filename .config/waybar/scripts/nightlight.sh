#!/bin/bash

set -u

NIGHT_OFF=""
NIGHT_ON="\uf186"

NIGHT_PID="$(pgrep wlsunset)"
if [ -z $NIGHT_PID ]; then
  printf '{"text": "%s", "tooltip": "Nightlight disabled"}' "$NIGHT_OFF"
else
  printf '{"text": "%s", "tooltip": "Nightlight enabled"}' "$NIGHT_ON"
fi
