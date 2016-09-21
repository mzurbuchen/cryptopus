#!/bin/bash
su - cryptopus
gem install bundler
bundle install --deployment --without 'development test'
