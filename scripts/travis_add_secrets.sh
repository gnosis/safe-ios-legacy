#! /usr/bin/env bash
set -e
keys=`cat .env.default`
for line in $keys; do
  set -- `echo $line | tr '=' ' '`
  echo "Adding $1"
  bundle exec travis encrypt $1=$2 --add --no-interactive
done
echo "All keys added to Travis config"

