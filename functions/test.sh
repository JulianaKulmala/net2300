#!/bin/sh
#test.sh
function alice {
  echo "alice: $@"
  echo "$0: $1 $2 $3 $4"
  echo "$# arguments"

}
alice in wonderland

