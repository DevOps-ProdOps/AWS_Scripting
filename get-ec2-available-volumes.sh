#!/bin/bash
#
# Copyright 2013, Ascendant Technology, LLC
#
# Created 2013-03-12 by Ramkumar Kuppuchamy <ramkumar.kuppuchamy@atech.com>
#
# Description:
# This script will get the EBS Non attached volumes with any of the instances in AWSMaster Account and will generate the CSV report
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

#Get all the available volumes under AWSMaster Account
echo 'Trying to get the Available (Not attached )EBS volumes !!!'

#Get the date in proper format to create the backup directory
current_timestamp=`date +%Y\-%m\-%d\_%H%M%S`
output_file=AWSMaster-ec2-available-volumes_$current_timestamp.csv

# Using the access and Secret key to authenticate

ec2-describe-volumes -O $EC2_ACCESS_KEY -W $EC2_SECRET_KEY -F status='available' > temp-available-volumes.txt

# Using .PEM files to authenticate

#ec2-describe-volumes -K $EC2_PK -C $EC2_CERT -F status='available' > temp-available-volumes.txt

echo "VolumeId,Size(GB),Region" > $output_file

echo 'Loaded the data in temp file'
awk 'BEGIN{ print "Begininng to process the data"  }
        {
                        print $2",",$3",",$5 >> "'"${output_file}"'"
         }
END { print "Processing done.....!!!"}' temp-available-volumes.txt

#Remove the temp files created for processing the data
echo "removing the unused temp files"

rm -f temp-available-volumes.txt

echo '============================================================='
echo 'Got the list of available volumes and stored in AWSMaster-available-ec2-volumes_<current_timestamp>..csv File !!'
echo '============================================================='

