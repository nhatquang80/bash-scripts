#!/bin/sh

# Make sure to:
# 1) Name this file `backup.sh` and place it in /home/ubuntu
# 2) Run sudo apt-get install awscli to install the AWSCLI
# 3) Run aws configure (enter s3-authorized IAM user and specify region)
# 4) Fill in DB host + name
# 5) Create S3 bucket for the backups and fill it in below (set a lifecycle rule to expire files older than X days in the bucket)
# 6) Run chmod +x backup.sh
# 7) Test it out via ./backup.sh
# 8) Set up a daily backup at midnight via `crontab -e`:
#    0 0 * * * /home/ubuntu/backup.sh > /home/ubuntu/backup.log

# DB host (secondary preferred as to avoid impacting primary performance)
HOST=localhost

# DB name
DBNAME=adtran
USERNAME=admin
PASSWORD='kNa8wmThPWRgK3Eg'

# S3 bucket name
BUCKET=adtran-indo-production-storage
FOLDER=db_backup

# Linux user account
USER=ubuntu

# Current time
TIME=`/bin/date +%Y%m%d%H%M%S`

# Backup directory
DEST=/home/ubuntu/backup_tmp/

# Tar file of backup directory
TAR=$DEST/mongodb_bak_$TIME.tar.gz

# Create backup dir (-p to avoid warning if already exists)
/bin/mkdir -p $DEST

# Log
echo "Backing up MongoDB at $HOST/$DBNAME to s3://$BUCKET/$FOLDER on $TIME"

# Dump from mongodb host into backup directory
/usr/bin/mongodump -h $HOST -d $DBNAME -o $DEST -p $PASSWORD -u $USERNAME --authenticationDatabase=admin

# Create tar of backup directory
/bin/tar -czvf $TAR -C $DEST .

# Upload tar to s3
/usr/bin/aws s3 cp $TAR s3://$BUCKET/$FOLDER/

# Remove tar file locally
/bin/rm -f $TAR

# Remove backup directory
/bin/rm -rf $DEST

# All done
echo "Backup available at https://s3.amazonaws.com/$BUCKET/$FOLDER/mongodb_bak_$TIME.tar.gz"

# Delete old files
echo "* Delete old backups"
/home/ubuntu/backup/s3-autodelete.sh