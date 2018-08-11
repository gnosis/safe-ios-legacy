#! /usr/bin/env bash
if [ "${ENCRYPTED_FILES_SECRET_KEY}" == "" ]; then
  echo "Please define ENCRYPTED_FILES_SECRET_KEY environment variable"
  exit 1
fi
DIR=encrypted_files
openssl aes-256-cbc -k "${ENCRYPTED_FILES_SECRET_KEY}" -in $DIR.tar.enc -out $DIR.tar -d
tar xvf $DIR.tar
rm -f $DIR.tar

