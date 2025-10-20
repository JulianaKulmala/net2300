#!/bin/sh
 
 fun() {
  echo "Combined value: $1"
}
awk -F, 'NR > 1 { print $1 "," $4}' net2300.csv |while read combo; do
  fun "$combo"
done
