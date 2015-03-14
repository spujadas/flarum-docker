# Dockerfile for Flarum, based on Flarum skeleton Vagrantfile
# (https://github.com/flarum/flarum/blob/master/Vagrantfile)
# which uses scripts from Vaprobash
# (https://github.com/fideloper/Vaprobash)

# Run with:
# docker-compose up flarum
# docker-compose run --service-ports flarum <custom command, e.g. /bin/bash>

FROM phusion/baseimage
MAINTAINER Sebastien Pujadas <sebastien@my_surname.net>
ENV REFRESHED_AT 2015-02-17


###############################################################################
#                                     PHP
###############################################################################

### update repository for PHP 5.6

# note: triggers non-fatal error due to non-ASCII characters in repo name
#       (gpg: key E5267A6C: public key "Launchpad PPA for Ond\xc5\x99ej Sur�" imported)

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \
	&& add-apt-repository -y ppa:ondrej/php5-5.6 \
	&& apt-key update \
	&& apt-get update -qq


### install base packages and PHP

RUN apt-get install -qqy curl unzip git-core ack-grep software-properties-common build-essential \
	php5-cli php5-fpm php5-mysql php5-pgsql php5-sqlite php5-curl php5-gd php5-gmp php5-mcrypt php5-memcached php5-imagick php5-intl php5-xdebug


### configure PHP (FPM and CLI)
ADD php-fpm.ini.sed /etc/php5/fpm/php.ini.sed
RUN sed -i.bak -f /etc/php5/fpm/php.ini.sed /etc/php5/fpm/php.ini && rm /etc/php5/fpm/php.ini.sed

ADD php-cli.ini.sed /etc/php5/cli/php.ini.sed
RUN sed -i.bak -f /etc/php5/cli/php.ini.sed /etc/php5/cli/php.ini && rm /etc/php5/cli/php.ini.sed

ADD php-fpm.conf.sed /etc/php5/fpm/php-fpm.conf.sed
RUN sed -i.bak -f /etc/php5/fpm/php-fpm.conf.sed /etc/php5/fpm/php-fpm.conf && rm /etc/php5/fpm/php-fpm.conf.sed

ADD www.conf.sed /etc/php5/fpm/pool.d/www.conf.sed
RUN sed -i.bak -f /etc/php5/fpm/pool.d/www.conf.sed /etc/php5/fpm/pool.d/www.conf && rm /etc/php5/fpm/pool.d/www.conf.sed

ADD xdebug.ini /etc/php5/mods-available/xdebug.ini


###############################################################################
#                                  nginx
###############################################################################

### install nginx

RUN add-apt-repository -y ppa:nginx/stable \
	&& apt-get update -qq \
	&& apt-get install -qqy nginx


### configure nginx

ADD nginx.conf.sed /etc/nginx/nginx.conf.sed
RUN sed -i.bak -f /etc/nginx/nginx.conf.sed /etc/nginx/nginx.conf && rm /etc/nginx/nginx.conf.sed
ADD nginx-localhost.conf /etc/nginx/sites-available/localhost
RUN rm -f /etc/nginx/sites-enabled/default \
	&& ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost

ADD php-fpm-nginx.ini.sed /etc/php5/fpm/php.ini.sed
RUN sed -i.bak -f /etc/php5/fpm/php.ini.sed /etc/php5/fpm/php.ini && rm /etc/php5/fpm/php.ini.sed


###############################################################################
#                                   MySQL
###############################################################################

# config.vm.provision "shell", path: "#{github_url}/scripts/mysql.sh", args: [mysql_root_password, mysql_version, mysql_enable_remote]

### install MySQL

RUN add-apt-repository -y ppa:ondrej/mysql-5.6 \
	&& apt-get update -qq
ADD mysql-debconf-selections /tmp/mysql-debconf-selections
RUN debconf-set-selections /tmp/mysql-debconf-selections && rm /tmp/mysql-debconf-selections
RUN apt-get install -qqy mysql-server-5.6

### configure MySQL

# As per http://txt.fliglio.com/2013/11/creating-a-mysql-docker-container/#comment-1600036544
ADD mysqld_bind_address_all.cnf /etc/mysql/conf.d/mysqld_bind_address_all.cnf
RUN chmod 644 /etc/mysql/conf.d/mysqld_bind_address_all.cnf

# http://txt.fliglio.com/2013/11/creating-a-mysql-docker-container/#comment-1566459566
RUN service mysql start \
	&& mysqladmin --silent --wait=30 ping \
	&& mysql -uroot -proot -e "GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;FLUSH PRIVILEGES;" \
	&& sleep 1 \
	&& service mysql stop


###############################################################################
#                                 memcached
###############################################################################

### install memcached

RUN apt-get install -qqy memcached


###############################################################################
#                                 beanstalkd
###############################################################################

### install beanstalkd

RUN apt-get install -qqy beanstalkd


###############################################################################
#                                  NodeJS
###############################################################################

### install NVM

RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.24.0/install.sh | bash

### install NodeJS and configure NPM
# but first create link from sh to bash (instead of dash) to be able to source files
RUN ln -sf /bin/bash /bin/sh

RUN . ~/.nvm/nvm.sh \
	&& nvm install 0.12.0 \
	&& nvm alias default 0.12.0 \
	&& nvm use default \
	&& npm config set prefix /opt/npm \
	&& echo -e "\nexport PATH=\$PATH:/opt/npm/bin\nexport NODE_PATH=\$NODE_PATH:/opt/npm/lib/node_modules" >> ~/.bashrc

ENV PATH $PATH:/opt/npm/bin
ENV NODE_PATH $NODE_PATH:/opt/npm/lib/node_modules


###############################################################################
#                                  Composer
###############################################################################

### install Composer

RUN curl -sS https://getcomposer.org/installer | php \
	&& sudo mv composer.phar /usr/local/bin/composer


###############################################################################
#                                   Flarum
###############################################################################

# prerequisites
RUN apt-get install -qqy phantomjs zsh exuberant-ctags

RUN . ~/.nvm/nvm.sh \
	&& npm install -g bower ember

ENV FLARUM_ROOT /opt/flarum

# download skeleton Laravel app
RUN mkdir -p ${FLARUM_ROOT} \
	&& cd ${FLARUM_ROOT} \
	&& git clone https://github.com/flarum/flarum .

# download core app
RUN mkdir -p ${FLARUM_ROOT}/flarum/core \
	&& cd ${FLARUM_ROOT}/flarum/core \
	&& git clone https://github.com/flarum/core . \
	&& mkdir public

# install core app PHP dependencies
RUN cd ${FLARUM_ROOT}/flarum/core \
	&& composer install --prefer-dist

# install core app JS dependencies
RUN cd ${FLARUM_ROOT}/flarum/core/ember \
	&& . ~/.nvm/nvm.sh \
	&& npm install \
	&& bower --allow-root install

# install skeleton app dependencies
RUN cd ${FLARUM_ROOT} \
	&& cp ${FLARUM_ROOT}/.env.example ${FLARUM_ROOT}/.env \
	&& composer install --prefer-dist

# create database, run installation migrations and seeds, seed database with fake data
RUN service mysql start \
	&& mysqladmin --silent --wait=30 ping \
	&& mysql -u root -proot -e 'create database flarum' \
	&& cd ${FLARUM_ROOT} \
	&& php artisan flarum:install \
	&& php artisan flarum:seed \
	&& sleep 1 \
	&& service mysql stop

RUN chown -R www-data ${FLARUM_ROOT}

EXPOSE 80
WORKDIR ${FLARUM_ROOT}

ADD ./start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
CMD [ "/usr/local/bin/start.sh" ]

