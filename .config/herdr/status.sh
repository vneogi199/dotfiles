#!/bin/sh

total=$(sysctl -n hw.memsize | awk '{printf "%.1f", $1 / 1024 / 1024 / 1024}')

stats=$(top -l 1 -n 0 | awk -v total="$total" '
/CPU usage:/ {
  gsub("%", "", $3)
  gsub("%", "", $5)
  printf "󰻠 %.0f%%", $3 + $5
}
/PhysMem:/ {
  value = $2
  unit = substr(value, length(value), 1)
  number = substr(value, 1, length(value) - 1)
  if (unit == "M") number /= 1024
  printf " · 󰍛 %.1f/%.1fGB", number, total
}')

# Battery: Nerd Font icon scales with level, ⚡ when charging.
batt_line=$(pmset -g batt 2>/dev/null | grep -o '[0-9]\+%; [a-z ]*; [0-9:]* remaining' | head -n 1)
if [ -n "$batt_line" ]; then
  pct=$(printf '%s' "$batt_line" | grep -o '^[0-9]\+')
  state=$(printf '%s' "$batt_line" | grep -o 'charging\|discharging\|charged\|finishing charge' | head -n 1)
  time_left=$(printf '%s' "$batt_line" | grep -o '[0-9]:[0-9][0-9]' | head -n 1)

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
      # Show time remaining only when discharging with a real estimate.
      if [ -n "$time_left" ] && [ "$time_left" != "0:00" ]; then
        batt=" · $icon $pct% ($time_left)"
      else
        batt=" · $icon $pct%"
      fi
      ;;
    *)
      if [ "$pct" -ge 90 ]; then icon="󰂅"; else icon="󰂄"; fi
      batt=" · $icon $pct% ⚡"
      ;;
  esac
  printf '%s%s' "$stats" "$batt"
else
  printf '%s' "$stats"
fi
