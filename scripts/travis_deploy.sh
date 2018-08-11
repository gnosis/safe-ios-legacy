#! /usr/bin/env sh

set -ev

sh scripts/decrypt_files.sh
pip install --user awscli
mkdir -p ~/$TRAVIS_BUILD_NUMBER
aws s3 sync s3://safe.gnosis.travis/$TRAVIS_BUILD_NUMBER ~/$TRAVIS_BUILD_NUMBER
bundle install --jobs=3 --retry=3 --deployment --path=${BUNDLE_PATH:-vendor/bundle}

set +e
bundle exec fastlane fabric
RESULT=$?
set -e

if [ $RESULT -eq 0 ]; then
    aws s3 rm --recursive s3://safe.gnosis.travis/$TRAVIS_BUILD_NUMBER
    tar -czf archive.tar.gz ./Build/Archive.xcarchive
    aws s3 sync archive.tar.gz s3://safe.gnosis.travis/$TRAVIS_BUILD_NUMBER/archive.tar.gz
else
    tar -czf ~/$TRAVIS_BUILD_NUMBER/deploy.tar.gz ./Build/build_logs/ ./Build/reports/ ./Build/pre_build_action.log
    aws s3 sync ~/$TRAVIS_BUILD_NUMBER s3://safe.gnosis.travis/$TRAVIS_BUILD_NUMBER
fi
