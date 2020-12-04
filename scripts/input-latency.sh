#!/usr/bin/env bash

stty -echo

i="0"
start=$(date +%s%6N)

while read -n 1 char; do
  end=$(($(date +%s%6N)-start))
  # Disregard the first and last 5 samples
  if [ $i -gt 4 ] && [ $i -lt 105 ] ; then
    result=${result}$(printf "%s;" "$end")
  fi
  # Break after 110 iterations
  if [ $i -gt 110 ]; then
    break
  fi
  i=$(($i+1))
  start=$(date +%s%6N)
done

stty echo

echo
echo "$result"
