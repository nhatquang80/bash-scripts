#!/bin/bash

# Maximum date (will delete all files older than this date)
maxDate=`date +%s --date="-30 days"`

# S3
S3_PATH="adtran-indo-production-storage/db_backup"

# Loop thru files
aws s3 ls s3://$S3_PATH/ | while read -r line;  do
    # Get file creation date
    createDate=`echo $line|awk {'print $1" "$2'}`
    createDate=`date -d"$createDate" +%s`

    if [[ $createDate -lt $maxDate ]]
    then
	# Get file name
        fileName=`echo $line|awk {'print $4'}`
        if [[ $fileName != "" ]]
          then
	      echo "* Delete $fileName";
	      aws s3 rm s3://$S3_PATH/$fileName
        fi
    fi
done;
