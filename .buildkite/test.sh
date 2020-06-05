#!/bin/sh
set -xe

bundle install
bundle exec bundle-audit check --update
bundle exec ruby-audit check
bundle exec rake
