if [ "$TRAVIS_PULL_REQUEST" = "false" ]; then
  bundle exec fastlane test
else
  bundle exec fastlane fabric
fi
