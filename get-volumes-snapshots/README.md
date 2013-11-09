#This will help you to get the print the report for 
# 1. Attached volumes to the instances
# 2. Snapshots for the volumes

For any queries contact : ramkumar.kuppuchamy@atech.com

Execute Instructions;
=======================
1. To generate the report run the script in the same directory
/home/ramkumar/scripts/MS-ATIC-Challenge-II :

To get the attached volumes -->  ms-scripting-challenge-2.sh -f <config_file> -v 
To get the snapshots 	    -->  ms-scripting-challenge-2.sh -f <config_file> -s

2. Pass the correct arguments based on the report needed

3. Redirect the output to the file if you want. It will print only in the
console

Technical Implementation:
==========================

1. Config file is under home /home/ramkumar/.config/.ec2_config -- used as a property file
