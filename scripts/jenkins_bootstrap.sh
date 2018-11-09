#! /usr/bin/env bash
set -e

if ! which rbenv > /dev/null; then
  echo "Installing rbenv"
  brew install rbenv
fi

if ! which openssl > /dev/null; then
  echo "Installing openssl"
  brew install openssl
fi

# if rbenv versinos does not contain project's ruby version, install project ruby version
PROJECT_RUBY_VERSION=$(cat .ruby-version)
if ! rbenv versions | grep $PROJECT_RUBY_VERSION > /dev/null; then
  echo "Installing Ruby $PROJECT_RUBY_VERSION"
  rbenv install $PROJECT_RUBY_VERSION
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
  echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
  source ~/.bash_profile
  rbenv rehash
fi

rbenv local ${PROJECT_RUBY_VERSION}

if ! rbenv which bundle > /dev/null; then
  echo "Installing bundler"
  gem install bundler
  rbenv rehash
fi
