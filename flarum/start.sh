#!/bin/bash

service php5-fpm start
service mysql start
service memcached start
service beanstalkd start
service nginx start

. ~/.nvm/nvm.sh
export PATH=$PATH:/opt/npm/bin
export NODE_PATH=$NODE_PATH:/opt/npm/lib/node_modules
cd /opt/flarum/flarum/core/ember && node_modules/ember-cli/bin/ember serve --output-path="../public"