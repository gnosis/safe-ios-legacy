#! /usr/bin/env bash
source .env.default
DIR=encrypted_files
rm -f $DIR.tar $DIR.tar.enc
tar cvf $DIR.tar $DIR
openssl aes-256-cbc -k "${ENCRYPTED_FILES_SECRET_KEY}" -in $DIR.tar -out $DIR.tar.enc
rm -f $DIR.tar

