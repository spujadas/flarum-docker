#!/bin/bash

service php5-fpm start
service mysql start
service memcached start
service beanstalkd start
service nginx start

tail -f /var/log/nginx/access.log
