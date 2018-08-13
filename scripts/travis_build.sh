#! /usr/bin/env bash
set -ev

function sync_to_aws() {
    aws s3 sync ~/$TRAVIS_BUILD_NUMBER s3://safe.gnosis.travis/$TRAVIS_BUILD_NUMBER
}

function archive_logs() {
    tar -czf ~/$TRAVIS_BUILD_NUMBER/logs.tgz ./Build/build_logs/ ./Build/reports/ ./Build/pre_build_action.log
    sync_to_aws
}

function archive_product() {
    tar -czf ~/$TRAVIS_BUILD_NUMBER/archive.tgz ./Build/Archive.xcarchive
    sync_to_aws
}

function archive_code_coverage() {
    bash <(curl -s https://codecov.io/bash) -D . -c
}

function prepare_build() {
    sh scripts/decrypt_files.sh
    pip install --user awscli
    mkdir -p ~/$TRAVIS_BUILD_NUMBER
    bundle install --jobs=3 --retry=3 --deployment --path=${BUNDLE_PATH:-vendor/bundle}
}

prepare_build

# if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
#     bundle exec fastlane test scheme:safe || archive_logs
# elif [ "$TRAVIS_EVENT_TYPE" = "cron" ]; then
#     bundle exec fastlane test scheme:allUITests || archive_logs
# else 
    if bundle exec fastlane fabric; then
         archive_product
         archive_code_coverage
    else
        archive_logs
        exit 1
    fi
# fi
