#!/bin/bash

# Git commit wrapper - progress bar ile göstermek için
commitMessage="$@"

# Progress bar göster
maxSteps=20
for i in $(seq 1 $maxSteps); do
    percent=$((i * 100 / maxSteps))
    bar=$(printf '=%.0s' $(seq 1 $i))
    empty=$(printf ' %.0s' $(seq 1 $((maxSteps - i))))
    printf "\r[%s%s] %d%%" "$bar" "$empty" "$percent"
    sleep 0.075
done

echo ""
