if [ "$TRAVIS_PULL_REQUEST" = "false" ]; then
  if [ "$TRAVIS_EVENT_TYPE" = "cron" ]; then
    bundle exec fastlane ui_test
  else
    bundle exec fastlane fabric
  fi
else
  bundle exec fastlane test
fi
