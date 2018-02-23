#if [ $TRAVIS_PULL_REQUEST ]; then
#    bundle exec fastlane test
#else
    bundle exec fastlane fabric
#fi
