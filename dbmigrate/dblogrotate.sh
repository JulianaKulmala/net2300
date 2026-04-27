#!/bin/bash

cd /root/net2300/dbmigrate

mv dbmigrate.log dbmigrate-$(date +%F).log
touch dbmigrate.log
echo "Rotated at $(date)" >> dbmigrate.log
