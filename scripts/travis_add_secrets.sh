#! /usr/bin/env bash
keys=`cat .env.default`
for line in $keys; do
  set -- `echo $line | tr -d '"' | tr '=' ' '`
  echo "Adding $1"
  ESCAPED_VALUE="'$(echo "$2" | sed -e 's/\([][{}(); !^$#\\&*]\)/\\\1/g')'"
  bundle exec travis encrypt $1=$ESCAPED_VALUE --add --no-interactive
done
echo "All keys added to Travis config"
