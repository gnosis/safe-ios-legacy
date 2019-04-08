#! /usr/bin/env bash

set -ex

export PATH="/usr/local/bin:$PATH"
export CI="true"
source ~/.bash_profile
scripts/jenkins_bootstrap.sh
scripts/decrypt_files.sh
cp encrypted_files/.env.default .env.default
source .env.default
bundle install --jobs=3 --retry=3

case "$1" in

test) bundle exec fastlane test scheme:safe
    curl -s https://codecov.io/bash | bash -s -- -D . -c -t "${CODECOV_TOKEN}"
    ;;
adhoc) bundle exec fastlane fabric
    ;;
smoketest) bundle exec fastlane test scheme:allUITests
    curl -s https://codecov.io/bash | bash -s -- -D . -c -t "${CODECOV_TOKEN}"
    ;;
*) echo "Invalid option"; exit 1;
    ;;
esac
