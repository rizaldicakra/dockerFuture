#!/bin/sh

# params
REDIS_HOST=${REDIS_HOST:-"redis"}
REDIS_PORT=${REDIS_PORT:-"6379"}
WP_DB=${WP_DB:-"wordpress"}
WP_USER=${WP_USER:-"admin"}
WP_PWD=${WP_PWD:-"admin"}
DB_HOST=${DB_HOST:-"mariadb"}

mkdir -p /var/www/html 
cd /var/www/html/
curl -fSL https://wordpress.org/wordpress-$WORDPRESS_VERSION.tar.gz -o wordpress.tar.gz 
tar -xzC /var/www/html --strip-components=1 -f wordpress.tar.gz 
rm -rf wordpress.tar.gz 
mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php 


# update wp-config
sed -i s/database_name_here/$WP_DB/ /var/www/html/wp-config.php
sed -i s/username_here/$WP_USER/ /var/www/html/wp-config.php
sed -i s/password_here/$WP_PWD/ /var/www/html/wp-config.php
sed -i s/localhost/$DB_HOST/ /var/www/html/wp-config.php

if [ ! -z "$USE_REDIS" ]; then
    sed -i s/"session.save_handler = files"/"session.save_handler = redis"/ /etc/php7/php.ini
    sed -i 's#;session.save_path = "/tmp"#session.save_path = "tcp://'$REDIS_HOST':'$REDIS_PORT'"#' /etc/php7/php.ini
    sed -i s/"'host'       =>.*"/"'host'       => '$REDIS_HOST',"/ /var/www/html/wp-content/plugins/redis/wp-redis-user-session-storage.php
fi

