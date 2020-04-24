#!/bin/bash

function exportBoolean {
    if [ "${!1}" = "**Boolean**" ]; then
            export ${1}=''
    else 
            export ${1}='Yes.'
    fi
}

exportBoolean LOG_STDOUT
exportBoolean LOG_STDERR

if [ $LOG_STDERR ]; then
    /bin/ln -sf /dev/stderr /var/log/apache2/error.log
else
	LOG_STDERR='No.'
fi

if [ $ALLOW_OVERRIDE == 'All' ]; then
    /bin/sed -i 's/AllowOverride\ None/AllowOverride\ All/g' /etc/apache2/apache2.conf
fi

if [ $LOG_LEVEL != 'warn' ]; then
    /bin/sed -i "s/LogLevel\ warn/LogLevel\ ${LOG_LEVEL}/g" /etc/apache2/apache2.conf
fi

# enable php short tags:
/bin/sed -i "s/short_open_tag\ \=\ Off/short_open_tag\ \=\ On/g" /etc/php/7.0/apache2/php.ini

# stdout server info:
if [ $LOG_STDOUT ]; then
    /bin/ln -sf /dev/stdout /var/log/apache2/access.log
fi

# Set PHP timezone
/bin/sed -i "s/\;date\.timezone\ \=/date\.timezone\ \=\ ${DATE_TIMEZONE}/" /etc/php/7.0/apache2/php.ini

# Run MariaDB
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1

	/usr/bin/mysqld_safe --timezone=${DATE_TIMEZONE}&

	RET=1
	while [[ RET -eq 1 ]]; do
		sleep 5
		RET=$(/etc/init.d/mysql status | grep stopped | wc -l);
	done

	mysql -uroot -e "DROP DATABASE IF EXISTS afterlogic"
	mysql -uroot -e "CREATE DATABASE afterlogic"
    mysql -uroot -e "CREATE USER 'rootuser'@'localhost' IDENTIFIED BY 'dockerbundle'"
	mysql -uroot -e "GRANT USAGE ON * . * TO 'rootuser'@'localhost' IDENTIFIED BY 'dockerbundle';"
	mysql -uroot -e "GRANT SELECT,ALTER,INSERT,UPDATE,DELETE,CREATE,DROP,INDEX,REFERENCES ON \`afterlogic\` . * TO 'rootuser'@'localhost';FLUSH PRIVILEGES;"
    mysql -uroot -e "SET PASSWORD FOR 'rootuser'@'localhost' = PASSWORD( 'dockerbundle' ); FLUSH PRIVILEGES;"
	
	echo "=> Database created!"

    php /var/www/html/afterlogic.php
else
    echo "=> Using an existing volume of MySQL"
fi

# Run Apache:
if [ $LOG_LEVEL == 'debug' ]; then
    /usr/sbin/apachectl -DFOREGROUND -k start -e debug
else
    &>/dev/null /usr/sbin/apachectl -DFOREGROUND -k start
fi
