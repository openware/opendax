#!/bin/bash -x

export RUBY_VERSION=$(sudo cat /home/deploy/opendax/.ruby-version)

sudo -u deploy bash <<EOS
  gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  curl -sSL https://get.rvm.io | bash -s stable

  source /home/deploy/.rvm/scripts/rvm
  cd /home/deploy
  rvm autolibs disable
  rvm requirements
  rvm install --quiet-curl $RUBY_VERSION
  rvm use --default $RUBY_VERSION
EOS
