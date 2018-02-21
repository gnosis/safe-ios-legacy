#! /usr/bin/env bash
set -ex

if ! which brew > /dev/null; then
  echo "Installing HomeBrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if ! which swiftlint > /dev/null; then
  echo "Installing SwiftLint"
  brew install swiftlint
fi

if ! which swiftgen > /dev/null; then
  echo "Installing SwiftGen"
  brew install swiftgen
fi

if ! which rbenv > /dev/null; then
  echo "Installing rbenv"
  brew install rbenv
fi

if ! rbenv versions | grep $(cat .ruby-version) > /dev/null; then
  echo "Installing Ruby $(cat .ruby-version)"
  rbenv install $(cat .ruby-version)
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
  echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
  source ~/.bash_profile
fi

if ! rbenv which bundle > /dev/null; then
  echo "Installing bundler"
  gem install bundler
fi

TEMPLATES_DIR=~/Library/Developer/Xcode/Templates/Gnosis
if [ ! -d $TEMPLATES_DIR ]; then
  echo "Installing Gnosis Xcode templates"
  mkdir -p $TEMPLATES_DIR
  cp -R xcode-templates/* $TEMPLATES_DIR/
fi

echo "Running bundle install"
bundle install

echo "Bootstrapping complete!"
