#!/usr/bin/env bash
# Create a ONE-OFF phone reminder via cron-job.org -> ntfy (no GitHub, no token).
# Fires once at the given IST time, then auto-expires so it never repeats.
#
# Usage: add-oneoff.sh "Title" "Message body" "YYYY-MM-DD HH:MM"
# Example: add-oneoff.sh "Take the Tshirts" "Drop them to Bethany. 👕" "2026-06-26 13:00"

set -euo pipefail

TITLE="${1:?need a title}"
MSG="${2:?need a message}"
WHEN="${3:?need a datetime: YYYY-MM-DD HH:MM}"

KEY="$(cat "$HOME/.cronjob_api_key")"

YEAR=${WHEN:0:4}; MON=${WHEN:5:2}; DAY=${WHEN:8:2}
HH=${WHEN:11:2}; MM=${WHEN:14:2}

# Expire ~10 min after fire time so the job self-deletes and never recurs.
EXP="$(TZ=Asia/Kolkata date -j -v+10M -f '%Y-%m-%d %H:%M' "$WHEN" '+%Y%m%d%H%M%S')"

curl -s -X PUT https://api.cron-job.org/jobs \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d "{\"job\":{\"url\":\"https://ntfy.sh/Adil-brain\",\"enabled\":true,\"title\":$(printf '%s' "$TITLE" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read()))'),\"requestMethod\":1,\"extendedData\":{\"headers\":{\"Title\":$(printf '%s' "$TITLE" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read()))')},\"body\":$(printf '%s' "$MSG" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read()))')},\"schedule\":{\"timezone\":\"Asia/Kolkata\",\"hours\":[$((10#$HH))],\"mdays\":[$((10#$DAY))],\"minutes\":[$((10#$MM))],\"months\":[$((10#$MON))],\"wdays\":[-1],\"expiresAt\":${EXP}}}}"
echo
echo "Scheduled: \"$TITLE\" for $WHEN IST (auto-expires ~10 min after)."
