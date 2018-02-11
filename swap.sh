#!/bin/bash

if free | awk '/^Swap:/ {exit !$2}'; then
    echo "Swap enabled already"
else
read -p "How much swap pace required ? (Please mention it in GB): " swaps
if [[ ! $swaps || $swaps = *[^0-9]* ]]; then
    echo "Error: '$swaps' is not a valid swap space entry. Please enter number of GB you require" >&2
else
fallocate -l ${swaps}G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon -s
echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab
fi
fi
