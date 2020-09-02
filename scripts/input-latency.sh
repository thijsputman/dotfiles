#!/usr/bin/env sh

stty raw

i="0"

while [ $i -lt 105 ]; do
  start=$(date +%s%6N)
  dd bs=1 count=1 2> /dev/null
  end=$(($(date +%s%6N)-start))
  # Disregard the first 5 samples
  if [ $i -gt 4 ]; then
    result=${result}$(printf "%s;" "$end")
  fi
  i=$(($i+1))
done

stty sane

echo
echo "$result"
