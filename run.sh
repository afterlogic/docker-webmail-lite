#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  

    /usr/bin/mysqld_safe > /dev/null 2>&1 &

    RET=1
    while [[ RET -ne 0 ]]; do
        sleep 5
        mysql -uroot -e "status" > /dev/null 2>&1
        RET=$?
    done

    mysqladmin -u root password webbundle
    mysql -uroot -pwebbundle -e "DROP DATABASE IF EXISTS afterlogic"
    mysql -uroot -pwebbundle -e "CREATE DATABASE afterlogic"

    echo "Database created!"

    php /var/www/html/afterlogic.php

    mysqladmin -u root -pwebbundle shutdown

else
    echo "=> Using an existing volume of MySQL"
fi

exec supervisord -n
