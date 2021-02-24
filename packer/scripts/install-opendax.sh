#!/bin/bash -x

sudo -u deploy bash <<EOS
  source /home/deploy/.rvm/scripts/rvm

  cd /home/deploy/opendax
  gem install bundler
  bundle install
  rake service:all
EOS
