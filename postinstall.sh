#!/bin/bash
su - cryptopus
cd /var/www/vhosts/cryptopus/www
bundle install --deployment --without 'development test'
