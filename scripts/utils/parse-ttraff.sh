#!/usr/bin/env bash

# Parse "traffdata.bak" (backup of ttraff-daemon data generated by the DD-WRT
# webinterface) into a format more agreeable with Excel.

while IFS= read -r line; do

  # shellcheck disable=SC2206
  data=($line)

  # Discard monthly totals
  unset "data[${#data[@]}-1]"

  # First array-entry contains year and month-number

  month=${data[0]}
  unset "data[0]"
  regex="traff-([0-9]{,2})-([0-9]{,4})=([0-9]+):([0-9]+)"

  if [[ $month =~ $regex ]]; then

    month=$((10#"${BASH_REMATCH[1]}"))
    year="${BASH_REMATCH[2]}"

    echo -e "$year\t$month\t1\t${BASH_REMATCH[3]}\t${BASH_REMATCH[4]}"
  fi

  # Loop over the remaining entries

  for i in "${!data[@]}"; do

    down=${data[$i]%:*}
    up=${data[$i]#*:}

    echo -e "$year\t$month\t$((i + 1))\t$down\t$up"

  done

done < "$1"
