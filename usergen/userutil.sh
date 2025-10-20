#!/bin/sh
 
 create_and_email() {
  echo "Combined value: $1"
}

mailcredentials() {
  echo "sending email to $1 "
  echo "Your user name is: $2, and your password is: $3"
}


awk -F, 'NR > 1 { print $1 "," $4}' net2300.csv |while read combo; do
  create_and_email "$combo"
done
