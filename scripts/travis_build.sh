if [ ${TRAVIS_BRANCH} = "master" ]; then
    bundle exec fastlane fabric
else
    bundle exec fastlane test
fi
