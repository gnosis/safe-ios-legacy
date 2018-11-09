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
fi

rbenv version
rbenv which ruby
rbenv which gem
rbenv rehash

if ! rbenv which bundle > /dev/null; then
  echo "Installing bundler"
  gem install bundler
  rbenv rehash
fi
