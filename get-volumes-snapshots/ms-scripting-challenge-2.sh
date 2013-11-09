#!/bin/bash
#
# Copyright 2013, Ascendant Technology, LLC
#
# Created 2013-04-02 by Ramkumar Kuppuchamy <ramkumar.kuppuchamy@atech.com>
#
# Description:
# This script will get the arguments for either getting the attached volumes for instances or snapshot report
#  for each volumes in AWSMaster Account and will print in the console
#
# Change Log: (Put in order from newest to oldest)
# 

# Function to print the help information to execute this script
print_help_fn()
{
	echo "---------------------------------------------------------------------------------------------"
	cat << EOF
	usage: $0 PARAMS [OPTIONS]

	Required Parameters:
	  -f	- The configuration file to load the AWS KEY, EC2 Environment properties

	[OPTIONS]
	  -v    - It will print the attached volumes for each instances
          -s    - It will print the snapshot for each volumes

	EX: $0 -f <config_file> -v
EOF
	echo "---------------------------------------------------------------------------------------------"

}

# Function to initalize the EC2 Environment properties file
init_properties_fn()
{
	echo "Trying to initialize the EC2 Environment properties file......"
        echo "--------------------------------------------------------"

        #Assigning the first argument to the configfile

        if [ -f $CONFIG_FILE ]; then

        #If the config file presents then source the file to load the environment variables
            . $CONFIG_FILE

            echo "Properties file loaded successfully...EC2 Environment is initialized successfull!!!"
            echo "-------------------------------------------------------"
	#Export the properties that need to be available to the environment
            export EC2_HOME JAVA_HOME PATH
        else
        # If the file not present then exit with error code
           echo "EC2 Environment setup Configuration file is missing!!"
           echo "-------------------------------------------------------"
           exit 1
        fi

}


#Function to get the attached volumes for each instances
get_volumes_fn()
{

	# get the all instance id's that are in the AWSMaster account
	#Create temp file to store the list of instances
	TEMP_FILE=`mktemp`
	echo "Temp file is created to hold the intermediate output $TEMP_FILE......"
	ec2-describe-instances -O $EC2_ACCESS_KEY -W $EC2_SECRET_KEY | grep 'INSTANCE' | awk 'BEGIN{}{ print $2 }END{}' > $TEMP_FILE
	#Get the attached volumes for the list of instances
	while read LINE;
	do
	   echo "---------------------------------------------------------------------------------"
	   echo "                    ATTACHED VOLUMES FOR INSTANCE $LINE"
	   echo "---------------------------------------------------------------------------------"
	#Get the attached volumes for the instances that we got from the previous command & print only volume ID,Size,Region
	 FLAG_VAR=`ec2-describe-volumes -O $EC2_ACCESS_KEY -W $EC2_SECRET_KEY -F "attachment.instance-id"=$LINE -F attachment.status='attached' | grep VOLUME | awk 'BEGIN{}{print $2,"\t",$3,"\t",$5}END{}'`

	#If no volumes are attached to this instance then print 'no volumes' message
	if [ -z "$FLAG_VAR" ]; then
	  echo " ************ NO VOLUMES ATTACHED TO THIS INSTANCE *********** "	   
	else
	  echo "$FLAG_VAR"
	fi

	done < $TEMP_FILE
	echo "Printed the attached volumes for the instances...!!!"
	#Remove the temporary file once the output is printed in the console
	echo "Cleaning the temp file......"
	rm $TEMP_FILE
	echo "Temp file cleanup is done...........!!"
}

#Function to get the snapshot for each volumes
get_snapshots_fn()
{
	#Get the list of volumes in the AWS Master account
	#Store the volume ids in the temp file
	TEMP_FILE=`mktemp`
	echo "Temp file is created to hold the intermediate output $TEMP_FILE......"
	ec2-describe-volumes -O $EC2_ACCESS_KEY -W $EC2_SECRET_KEY | grep VOLUME | awk 'BEGIN{}{print $2}END{}' > $TEMP_FILE
	 #Get the snapshot for the list of volumes
        while read LINE;
        do
           echo "---------------------------------------------------------------------------------"
           echo "                    SNAPSHOT FOR THE VOLUME $LINE"
           echo "---------------------------------------------------------------------------------"

        #Get the snapshot for the volume that we got from the previous command & print only Snapshot ID,Date,Description
	FLAG_VAR=`ec2-describe-snapshots -O $EC2_ACCESS_KEY -W $EC2_SECRET_KEY -F "volume-id=$LINE" | grep SNAPSHOT | awk 'BEGIN{}{print $2,"\t",substr($5,0,10),"\t",$9}END{}'`

	#If no snapshots are attached to this volume then printing the 'no snapshot' message
	if [ -z "$FLAG_VAR" ]; then
		echo "  ************ NO SNOPSHOTS ATTACHED TO THIS VOLUME *********** "
	else
		echo "$FLAG_VAR"
        fi
	done < $TEMP_FILE
	echo "Printed the snapshots for each volume....!!!"
	#Remove the temporary file once the output is printed in the console
        echo "Cleaning the temp file......"
        rm -rf  $TEMP_FILE
        echo "Temp file cleanup is done...........!!"


}


# Validating the number of arguments passed for the execution
if [ -z $1 ]; then
	echo "            No arguments specified to begin the process!!!"
#Call the function to print the help info to the user & exit
	print_help_fn
	exit 1
elif [ $# -lt 3 ]; then 
	echo "            Insufficient arguments to begin the process!!!"
#Call the function to print the help info to the user & exit
	print_help_fn
        exit 1
elif [ $# -gt 3 ]; then
	echo "            Too many arguments passed to begin the process!!! "
#Call the function to print the help info to the user & exit
	print_help_fn
	exit 1
else
#if the all the required options are passed the continuing the script execution
# using the getopts to validate that the option is either '-f' or '-o'
  while getopts "f:vs" opt; 
  do
   case $opt in  
        f)
	#Assigning the -f option value to the configfile to use it in functions
	CONFIG_FILE=$OPTARG
	;;
	v)
	#Assigning the -o option value to the Report_to_generate 
	#Call the specific functions based on the values received for generating output
		echo "======================== Getting attached volumes for each instances is started================="
	#Call the function to initialize the environment properties
		init_properties_fn  
	#Call the function to get the attached volumes to each instances
		get_volumes_fn
		echo " =================== Getting attached volumes for each instances is Ended ======================"
	;;
	s)
		echo " ======================== Getting snapshots for each volumes is started ========================"
	 #Call the function to initialize the environment properties
	        init_properties_fn
	 #Call the function to get the snapshots for each volumes
		get_snapshots_fn
		echo " ======================  Getting snapshots for each volumes is Ended  =========================="
        ;;
	\?) 
	  echo "The option used is not a valid option for this script!!!"
	#Call the function to print the help info to the user & exit
	  print_help_fn
	  exit 2
        ;;
	:) 
	  echo "The option used is not a valid option for this script!!!"
        #Call the function to print the help info to the user & exit
	  print_help_fn
          exit 2
        ;;

   esac
 done
fi
