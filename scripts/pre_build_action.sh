#! /usr/bin/env sh

set -ex

cd ${SRCROOT}/..
if [ ! -e AppConfig.yml ]; then
  cp encrypted_files/AppConfig.yml .
fi

ruby scripts/config2json.rb AppConfig.yml ${CONFIGURATION} > AppConfig.json
ruby scripts/config2env.rb AppConfig.yml ${CONFIGURATION} > AppConfig.xcconfig

