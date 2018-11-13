#! /usr/bin/env sh

set -ex

cd ${SRCROOT}/..
if [ ${CONFIGURATION} == 'PreRelease' ] || [ ${CONFIGURATION} == 'Release' ]; then
  source .env.default && export ENCRYPTED_FILES_SECRET_KEY && ./scripts/decrypt_files.sh
  cp encrypted_files/AppConfig.yml .
elif [ ! -e AppConfig.yml ]; then
  cp encrypted_files/AppConfig.yml .
fi


ruby scripts/config2json.rb AppConfig.yml ${CONFIGURATION} > AppConfig.json
ruby scripts/config2env.rb AppConfig.yml ${CONFIGURATION} > AppConfig.xcconfig

cp encrypted_files/GoogleService-Info-${CONFIGURATION}.plist ${SRCROOT}/safe/GoogleService-Info.plist
