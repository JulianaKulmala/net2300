#!/bin/sh

function name { 
  ls afolder      	# This succeeds (status 0)
  return              	# Returns 0
}

function name1 { 
  ls bfolder    	 # This fails (status 2)
  return        	  # Returns 2
}
name
echo $?
name1
echo $?

