#!/bin/sh
# herdr tab bar status (compact): CPU% · RAM% · net total · batt%

total_mb=$(sysctl -n hw.memsize | awk '{printf "%d", $1 / 1024 / 1024}')
total_gb=$(awk -v m="$total_mb" 'BEGIN {printf "%.1f", m / 1024}')

stats=$(top -l 1 -n 0 | awk -v total_mb="$total_mb" -v total_gb="$total_gb" '
/CPU usage:/ {
  gsub("%", "", $3)
  gsub("%", "", $5)
  printf "󰻠 %.0f%%", $3 + $5
}
/PhysMem:/ {  value = $2
  unit = substr(value, length(value), 1)
  number = substr(value, 1, length(value) - 1) + 0
  if (unit == "M") used_mb = number
  else if (unit == "G") used_mb = number * 1024
  else if (unit == "K") used_mb = number / 1024
  else used_mb = number / 1024
  # Percent only: compact + visibly updating (MB/GB rounding looked frozen).
  printf " · 󰍛 %d%%", used_mb * 100 / total_mb
}')

# --- Network throughput (delta of en* byte counters between runs) ---
format_rate() {
  awk -v b="$1" 'BEGIN {
    if (b < 1024) printf "%dB", b
    else if (b < 1048576) printf "%.1fK", b / 1024
    else printf "%.1fM", b / 1048576
  }'
}

STATE_FILE="${TMPDIR:-/tmp}/herdr_net_state"
RATE_CACHE="${TMPDIR:-/tmp}/herdr_net_rate"
# ms-resolution clock: herdr re-runs this script every 2s itself, so two writers
# can land in the same wall-clock second (dt=0 -> flickering "--").
now=$(perl -MTime::HiRes=time -e 'printf "%d", time * 1000' 2>/dev/null)
if [ -z "$now" ]; then
  now=$(($(date +%s) * 1000))
fi
cur=$(netstat -ibn 2>/dev/null | awk 'index($3, "Link") > 0 && substr($1, 1, 2) == "en" {rx += $(NF-4); tx += $(NF-1)} END {print rx + 0, tx + 0}')
cur_rx=$(printf '%s' "$cur" | awk '{print $1}')
cur_tx=$(printf '%s' "$cur" | awk '{print $2}')

net=""
if [ -f "$STATE_FILE" ]; then
  # shellcheck disable=SC2162
  read -r prev_now prev_rx prev_tx < "$STATE_FILE" 2>/dev/null
  # Tolerate state written by the older seconds-based version of this script.
  case "$prev_now" in
    ??????????) prev_now=$((prev_now * 1000)) ;;
  esac
  dt=$((now - prev_now))
  if [ -n "$prev_now" ] && [ "$dt" -gt 0 ]; then
    drx=$((cur_rx - prev_rx))
    dtx=$((cur_tx - prev_tx))
    # Counter reset (reboot/interface flap) -> show idle instead of garbage.
    if [ "$drx" -lt 0 ]; then drx=0; fi
    if [ "$dtx" -lt 0 ]; then dtx=0; fi
    down=$(format_rate $((drx * 1000 / dt)))
    up=$(format_rate $((dtx * 1000 / dt)))
    net=" · ↓${down} ↑${up}"
    printf '%s' "$net" > "$RATE_CACHE" 2>/dev/null
  elif [ -f "$RATE_CACHE" ]; then
    # Same-millisecond rerun (e.g. manual run colliding with herdr's own
    # 2s loop): reuse last rate instead of flickering "--".
    net=$(cat "$RATE_CACHE" 2>/dev/null)
  fi
fi
printf '%s %s %s\n' "$now" "$cur_rx" "$cur_tx" > "$STATE_FILE" 2>/dev/null
if [ -z "$net" ]; then
  if [ -f "$RATE_CACHE" ]; then
    net=$(cat "$RATE_CACHE" 2>/dev/null)
  else
    net=" · ↓-- ↑--"
  fi
fi

# Battery: icon + % only (no time estimate). ⚡ when charging.
batt_line=$(pmset -g batt 2>/dev/null | grep -o '[0-9]\+%; [a-z ]*' | head -n 1)
if [ -n "$batt_line" ]; then
  pct=$(printf '%s' "$batt_line" | grep -o '^[0-9]\+')
  state=$(printf '%s' "$batt_line" | grep -o 'charging\|discharging\|charged\|finishing charge' | head -n 1)

  case "$state" in
    discharging*)
      if [ "$pct" -ge 90 ]; then icon="󰁹"
      elif [ "$pct" -ge 80 ]; then icon="󰂂"
      elif [ "$pct" -ge 70 ]; then icon="󰂁"
      elif [ "$pct" -ge 60 ]; then icon="󰂀"
      elif [ "$pct" -ge 50 ]; then icon="󰁿"
      elif [ "$pct" -ge 40 ]; then icon="󰁾"
      elif [ "$pct" -ge 30 ]; then icon="󰁽"
      elif [ "$pct" -ge 20 ]; then icon="󰁼"
      elif [ "$pct" -ge 10 ]; then icon="󰁻"
      else icon="󰂎"
      fi
      # Compact: icon + % only, no time remaining.
      batt=" · $icon $pct%"
      ;;
    *)
      if [ "$pct" -ge 90 ]; then icon="󰂅"; else icon="󰂄"; fi
      batt=" · $icon $pct% ⚡"
      ;;
  esac
  printf '%s%s%s' "$stats" "$net" "$batt"
else
  printf '%s%s' "$stats" "$net"
fi
