#!/bin/bash

SRC_DIR="/home/ubuntu/s3-creative-rar/"
BUCKET="adtran-taiwan-dev-storage"

echo "Clear $SRC_DIR folder"
rm -rf "$SRC_DIR"*

echo "Download creative .rar from S3"

aws s3 cp s3://"$BUCKET"/creative/ "$SRC_DIR" --exclude "*" --include "*.rar" --recursive

cd "$SRC_DIR"

for file in *.rar
do

  if [ ! -e "$file" ];
  then
    echo "=== No .rar file found ==="
    exit
  fi

  echo "Extracting $file file..."

  BASENAME=`basename "${file%.*}"`

  mkdir "$BASENAME"

  unrar x -r -o+ "$file" "$BASENAME/"

  zip -r -9 "$BASENAME.zip" "$BASENAME/"

  # Upload zip to S3
  aws s3 cp "$SRC_DIR" s3://"$BUCKET"/creative/ --exclude "*" --include "*.zip" --recursive

  # Move .rar files to creative_success/ folder
  aws s3 mv s3://"$BUCKET"/creative/"$file" s3://"$BUCKET"/creative_success/
done
