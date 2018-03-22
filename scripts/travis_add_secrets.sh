#! /usr/bin/env bash
keys=`cat .env.default`
for line in $keys; do
  set -- `echo $line | tr '=' ' '`
  if [[ "$1" == "FASTLANE_USER" || "$1" == "FASTLANE_PASSWORD" ]]; then
    continue
  fi
  echo "Adding $1"
  bundle exec travis encrypt $1=$2 --add --no-interactive
done
echo "All keys added to Travis config"
