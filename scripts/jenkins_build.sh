#! /usr/bin/env bash

set -ex

export PATH="/usr/local/bin:$PATH"
export CI="true"
source ~/.bash_profile
scripts/jenkins_bootstrap.sh
scripts/decrypt_files.sh
cp encrypted_files/.env.default .env.default
bundle install --jobs=3 --retry=3

case "$1" in

test) bundle exec fastlane test scheme:safe
    ;;
adhoc) bundle exec fastlane fabric --verbose
    ;;
*) echo "Invalid option"; exit 1;
    ;;
esac