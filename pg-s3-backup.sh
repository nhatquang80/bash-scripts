#!/bin/bash

# Database credentials
PG_HOST="localhost"
PG_USER="postgres"

# S3
S3_PATH="adtran-indo-production-storage/db_backup"

# get databases list
dbs=("adtran")

# Vars
NOW=$(date +"%Y%m%d%H%M%S")
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FILENAME=postgres_bak_"$NOW".dump
TAR=postgres_bak_"$NOW".tar.gz
# Backup directory
DEST=/home/ubuntu/backup_tmp

# Create backup dir (-p to avoid warning if already exists)
mkdir -p $DEST

for db in "${dbs[@]}"; do
    # Dump database
    pg_dump -Fc -h $PG_HOST -U $PG_USER $db > $DEST/$FILENAME
    
    # Create tar of backup directory
    tar -czvf $DEST/$TAR $DEST/$FILENAME

    # Copy to S3
    aws s3 cp $DEST/$TAR s3://$S3_PATH/

    # Log
    echo "* Database $db is archived"
done

# Remove backup directory
rm -rf $DEST

# Delere old files
echo "* Delete old backups";
$DIR/s3-autodelete.sh

