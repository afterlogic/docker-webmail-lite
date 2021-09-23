#!/bin/bash

function exportBoolean {
  if [ "${!1}" = "**Boolean**" ]; then
    export ${1}=''
  else
    export ${1}='Yes.'
  fi
}

function runMariaDB() {
  /usr/bin/mysqld_safe --timezone=${DATE_TIMEZONE}&

  RET=1
  while [[ RET -eq 1 ]]; do
    sleep 5
    RET=$(/etc/init.d/mysql status | grep stopped | wc -l);
  done
}

function countFilesInDir() {
    find $1 -maxdepth 1 -not -path '*/.*' -not -path $1 2>/dev/null | wc -l
}

function mergeConfig() {
    jq -s '.[0] * .[1]' $1 $2 > /tmp/tempConfig.json && mv -f /tmp/tempConfig.json $1
}

function applyUserConfigOverrides() {
  configOverridesDir=$1
  echo "=> Applying user config overrides"

  settingsDirPath=/var/www/html/data/settings

  mainConfigFile=$configOverridesDir/config.json
  if [[ -f $mainConfigFile ]]; then
    echo "=> Processing $mainConfigFile"
    mergeConfig $settingsDirPath/config.json $mainConfigFile
  fi

  if [[ $(countFilesInDir $configOverridesDir/modules) -gt 0 ]]; then
    echo "=> Applying modules configs"
    for moduleConfig in $configOverridesDir/modules/*; do
      echo "=> Processing $moduleConfig"
      configFilePath="${moduleConfig##$configOverridesDir/}"
      mergeConfig $settingsDirPath/$configFilePath $configOverridesDir/$configFilePath
    done
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
/bin/sed -i "s/short_open_tag\ \=\ Off/short_open_tag\ \=\ On/g" /etc/php/7.4/apache2/php.ini

# stdout server info:
if [ $LOG_STDOUT ]; then
  /bin/ln -sf /dev/stdout /var/log/apache2/access.log
fi

# Set PHP timezone
/bin/sed -i "s/\;date\.timezone\ \=/date\.timezone\ \=\ ${DATE_TIMEZONE}/" /etc/php/7.4/apache2/php.ini

# Initialize databases if none
if [[ ! -d /var/lib/mysql/afterlogic ]]; then
  echo "=> Creating database..."
  mysql_install_db > /dev/null 2>&1

  runMariaDB

  mysql -uroot -e "CREATE DATABASE afterlogic"
  mysql -uroot -e "CREATE USER 'rootuser'@'localhost' IDENTIFIED BY 'dockerbundle'"
  mysql -uroot -e "GRANT USAGE ON * . * TO 'rootuser'@'localhost' IDENTIFIED BY 'dockerbundle';"
  mysql -uroot -e "GRANT SELECT,ALTER,INSERT,UPDATE,DELETE,CREATE,DROP,INDEX,REFERENCES ON \`afterlogic\` . * TO 'rootuser'@'localhost';FLUSH PRIVILEGES;"
  mysql -uroot -e "SET PASSWORD FOR 'rootuser'@'localhost' = PASSWORD( 'dockerbundle' ); FLUSH PRIVILEGES;"

  echo "=> Database created!"

  php /var/www/html/afterlogic.php

  chown -R www-data:www-data /var/www/html/data
  chmod -R 0777 /var/www/html/data
else
  echo "=> Using an existing database"
  runMariaDB
fi

if [[ $(countFilesInDir /opt/afterlogic/data/settings) -gt 0 ]]; then
  applyUserConfigOverrides /opt/afterlogic/data/settings
fi

# Run Apache:
if [ $LOG_LEVEL == 'debug' ]; then
  /usr/sbin/apachectl -DFOREGROUND -k start -e debug
else
  &>/dev/null /usr/sbin/apachectl -DFOREGROUND -k start
fi
