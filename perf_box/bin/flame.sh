#!/bin/bash

set -e

# Usage statement
usage() {
  echo "Usage: $0 [-h] [-p pid] [-f frequency] [-s sleep_seconds]"
  echo "  -h: Show this help message"
  echo "  -p: process id"
  echo "  -f: frequency"
  echo "  -s: sleep seconds"
}

# Parse options
while getopts "hp:f:s:" opt; do
  case ${opt} in
    h )
      usage
      exit 0
      ;;
    p )
      process_id=$OPTARG
      echo "arg process_id="$process_id
      ;;
    f )
      frequency=$OPTARG
      echo "arg frequency=$frequency"
      ;;
    s )
      sleep_seconds=$OPTARG
      echo "arg sleep_seconds=$sleep_seconds"
      ;;
    \? )
      usage
      exit 1
      ;;
  esac
done

# default value of options
frequency=${frequency:-99}
sleep_seconds=${sleep_seconds:-30}
perf_folded_res_file=result/out.perf-folded
perf_svg_file=result/perf.svg
perf_data_file=result/perf.data

echo "frequency=$frequency"
echo "sleep_seconds=$sleep_seconds"

# check command installed
if ! [ -x "$(command -v perf)" ]; then
  echo 'Error: perf is not installed.' >&2
  exit 1
fi

if [ -z $process_id ]; then
  perf record -F $frequency -a -g -o $perf_data_file -- sleep $sleep_seconds 
else
  perf record -F $frequency -a -g -o $perf_data_file -p $process_id -- sleep $sleep_seconds 
fi

perf script -i $perf_data_file | ../FlameGraph/stackcollapse-perf.pl > $perf_folded_res_file
../FlameGraph/flamegraph.pl $perf_folded_res_file > $perf_svg_file

echo "perf flame graph generated at $pwd/$perf_svg_file"

