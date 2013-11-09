#!/bin/bash
#
# Copyright 2013, Ascendant Technology, LLC
#
# Created 2013-03-12 by Ramkumar Kuppuchamy <ramkumar.kuppuchamy@atech.com>
#
# Description:
# This script will give the option for the CSV report to generate
#
#
# Change Log: (Put in order from newest to oldest)
# 03 12 2013 Ramkumar Kuppuchamy <ramkumar.kuppuchamy@atech.com>
#   - change 1
#   Modified the alignment of the script for the easy understanding
#  

# display options

while :
 do

	echo "Enter the option for which you want to generate report."
	echo "       1.List Running Instances"
	echo "       2.List Available(Non Attached) Volumes"
	echo "       3.Exit"
	read option
     case $option in 
# Call the script that generates report for running instances
	1)
	  echo "***************************************************************"
          echo "Generating Report for Running instances is started ..........."
	  echo "***************************************************************"

	  . ./get-ec2-running-insts.sh;;


# Call the script that generates report for available volumes

	2)
	  echo "***************************************************************"
	  echo "Generating Report for Available volumes is started ..........."
	  echo "***************************************************************"

	  . ./get-ec2-available-volumes.sh;;


#Exit the menu
	3) exit 0 ;;
#Other options are invalid

	*) echo "Invalid Option!"
    esac
 done
