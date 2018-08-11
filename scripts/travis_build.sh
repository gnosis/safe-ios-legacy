#! /usr/bin/env sh

# if [ "$TRAVIS_PULL_REQUEST" = "false" ]; then
#   # Cron job is triggerred daily
#   if [ "$TRAVIS_EVENT_TYPE" = "cron" ]; then
#     bundle exec fastlane ui_test
#   else
#     bundle exec fastlane fabric
#   fi
# else
#   bundle exec fastlane test
# fi

set -ev
sh scripts/decrypt_files.sh
pip install --user awscli
mkdir -p ~/$TRAVIS_BUILD_NUMBER
aws s3 sync s3://safe.gnosis.travis/$TRAVIS_BUILD_NUMBER ~/$TRAVIS_BUILD_NUMBER
bundle install --jobs=3 --retry=3 --deployment --path=${BUNDLE_PATH:-vendor/bundle}

bundle exec fastlane build_for_testing

tar -czf ~/$TRAVIS_BUILD_NUMBER/build_products.tar.gz ./Build/Products/ ./Build/build_logs/ ./Build/pre_build_action.log
aws s3 sync ~/$TRAVIS_BUILD_NUMBER s3://safe.gnosis.travis/$TRAVIS_BUILD_NUMBER