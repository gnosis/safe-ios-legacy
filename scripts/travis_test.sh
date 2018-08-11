#! /usr/bin/env sh

set -ev

sh scripts/decrypt_files.sh
pip install --user awscli
mkdir -p ~/$TRAVIS_BUILD_NUMBER
aws s3 sync s3://safe.gnosis.travis/$TRAVIS_BUILD_NUMBER ~/$TRAVIS_BUILD_NUMBER
bundle install --jobs=3 --retry=3 --deployment --path=${BUNDLE_PATH:-vendor/bundle}
tar -xzf ~/$TRAVIS_BUILD_NUMBER/build_products.tar.gz

bundle exec fastlane test_all $TEST_SUITE

tar -czf ~/$TRAVIS_BUILD_NUMBER/$TEST_SUITE_NAME.tar.gz ./Build/build_logs/ ./Build/reports/ ./Build/pre_build_action.log
aws s3 sync ~/$TRAVIS_BUILD_NUMBER s3://safe.gnosis.travis/$TRAVIS_BUILD_NUMBER