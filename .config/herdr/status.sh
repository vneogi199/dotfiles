#!/bin/sh

total=$(sysctl -n hw.memsize | awk '{printf "%.1f", $1 / 1024 / 1024 / 1024}')

top -l 1 -n 0 | awk -v total="$total" '
/CPU usage:/ {
  gsub("%", "", $3)
  gsub("%", "", $5)
  printf "CPU %.0f%%", $3 + $5
}
/PhysMem:/ {
  value = $2
  unit = substr(value, length(value), 1)
  number = substr(value, 1, length(value) - 1)
  if (unit == "M") number /= 1024
  printf " · RAM %.1f/%.1fGB", number, total
}'
