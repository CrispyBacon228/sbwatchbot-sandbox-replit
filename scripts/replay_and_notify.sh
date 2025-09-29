chmod +x scripts/replay_and_notify.sh
#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/replay_and_notify.sh 2025-09-27
DAY="${1:-$(date -u +%F)}"     # defaults to today (UTC)
CSV="replay_${DAY}.csv"

# load secrets from .env
set -a; [ -f .env ] && . .env; set +a

# run replay -> write CSV in CWD, then move to out/
sbwatch replay run --date "$DAY" --out . --csv "$CSV"
mkdir -p out
mv -f "$CSV" "out/$CSV"

# simple Discord ping (message)
if [ -n "${DISCORD_WEBHOOK_URL:-}" ]; then
  curl -sS -H "Content-Type: application/json" \
    -d "{\"content\":\"Replay ${DAY} finished ✅ (saved: out/${CSV})\"}" \
    "$DISCORD_WEBHOOK_URL" >/dev/null
fi

# optional: attach the CSV file to Discord (uncomment if you want the file uploaded)
# if [ -n "${DISCORD_WEBHOOK_URL:-}" ]; then
#   curl -sS -F "payload_json={\"content\":\"CSV attached for ${DAY}\"}" \
#           -F "file=@out/${CSV}" \
#           "$DISCORD_WEBHOOK_URL" >/dev/null
# fi

echo "Done: out/${CSV}"

