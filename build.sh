set -a
BUILD_PLATFORMS='epel-7-x86_64'
PULP_REPO=puzzle-autobuild-cryptopus2
RAILS_ENV='production'
RAILS_DB_HOST='pitc-cryptopus.db.puzzle.ch'
RAILS_DB_PORT=3306
RAILS_DB_ADAPTER='mysql2'
RAILS_DB_USERNAME='pitc_cryptopus_prod'
RAILS_DB_PASSWORD=gesundheit
RUBY_VERSION=2.2.4
RAILS_USE_RUBY=rvm
BUILD_NUMBER=3

bash config/rpm/build_rpm.sh
