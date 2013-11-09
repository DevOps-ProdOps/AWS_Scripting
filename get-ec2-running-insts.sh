#!/bin/bash
#
# Copyright 2013, Ascendant Technology, LLC
#
# Created 2013-03-12 by Ramkumar Kuppuchamy <ramkumar.kuppuchamy@atech.com>
#
# Description:
# This script will get the EC2 running instances in AWSMaster Account and will generate the CSV report
#
# Change Log: (Put in order from newest to oldest)

#   - Change 1
# % 03 12 2013 Ramkumar Kuppuchamy <ramkumar.kuppuchamy@atech.com
# Change the config file path from root path instead of getting from home dir and assigned to global variable
#   -  Change 2
# % 03 27 2013 Ramkumar Kuppuchamy <ramkumar.kuppuchamy@atech.com
#   1.  The environment variables are exported only when it is required.
#   2. Changed the Authentication from .PEM files to ACCESS & SECRET KEY
#   3. The output file is appended with the current timestamp


#Sourcing the environment initialization script to export the EC2 PATH

CONFIG_FILE=/home/ramkumar/.config/.ec2_config

if [ -f $CONFIG_FILE ]; then
    . $CONFIG_FILE
    export EC2_HOME JAVA_HOME PATH
else
    echo "EC2 Environment setup Configuration file is missing!!!"
    exit 1
fi


echo '============================================================='
echo 'Environment is Initialized....!!!'
echo '============================================================='

#Get all the list of instances that are running under AWSMaster Account
echo 'Trying to get the running instances!!!'

#Get the date in proper format to create the backup directory
current_timestamp=`date +%Y\-%m\-%d\_%H%M%S`
output_file=AWSMaster-ec2-running-instances_$current_timestamp.csv

# Using the Access Key and Secret Key
 
ec2-describe-instances -F instance-state-code=16 -O $EC2_ACCESS_KEY -W $EC2_SECRET_KEY  > temp-running-instances.txt 

# Using the .PEM file for authentication

#ec2-describe-instances -F instance-state-code=16 -K $EC2_PK -C $EC2_CERT  > temp-running-instances.txt

echo 'Loaded the data in temp file to process'

#Creat and Open the file AWSMaster-ec2-running-instances.txt for report
echo "Instance ID,Inst Name/DNS, InstStatus, InstRegion,"  > $output_file
awk 'BEGIN{ print "Processing the data has been started"  } 
	{ 
		resourcetype = $1
		if(resourcetype=="INSTANCE"){
			print $2",",$4",",$6",",$11 >> "'"${output_file}"'"
		}
	}
END { print "Data Processing is done!!!"}' temp-running-instances.txt


echo "Removing the temp files..."
rm -f temp-running-instances.txt

echo '============================================================='
echo 'Got the list of running instances and stored in AWSMaster-ec2-running-instances_<current_timestamp>.csv!!'
echo '============================================================='
