if [ "$TRAVIS_PULL_REQUEST" = "false" ]; then
  bundle exec fastlane fabric
else
  bundle exec fastlane test
fi
