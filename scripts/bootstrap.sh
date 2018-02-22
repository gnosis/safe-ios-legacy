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

# if rbenv versinos does not contain project's ruby version, install project ruby version
PROJECT_RUBY_VERSION=$(cat .ruby-version)
if ! rbenv versions | grep $PROJECT_RUBY_VERSION > /dev/null; then
  echo "Installing Ruby $PROJECT_RUBY_VERSION"
  brew upgrade ruby-build
  rbenv install $PROJECT_RUBY_VERSION
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
