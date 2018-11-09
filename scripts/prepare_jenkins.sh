#! /usr/bin/env bash

export PATH="/usr/local/bin:$PATH"
export CI="true"
source ~/.bash_profile
scripts/jenkins_bootstrap.sh
scripts/decrypt_files.sh
cp encrypted_files/.env.default .env.default
bundle install --jobs=3 --retry=3
