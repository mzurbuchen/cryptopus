#!/bin/bash
gem install bundler
bundle install --deployment --without 'development test'
