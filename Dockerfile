FROM ubuntu:16.04
MAINTAINER AfterLogic Support <support@afterlogic.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y \
	wget \
	zip \
	unzip \
	php7.0 \
	php7.0-cli \
	php7.0-common \
	php7.0-curl \
	php7.0-json \
	php7.0-mbstring \
	php7.0-mysql \
	php7.0-xml \
	apache2 \
	libapache2-mod-php7.0 \
	mariadb-common \
	mariadb-server \
	mariadb-client
	
ENV LOG_STDOUT **Boolean**
ENV LOG_STDERR **Boolean**
ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC

COPY run-lamp.sh /usr/sbin/
RUN chmod +x /usr/sbin/run-lamp.sh
COPY apache.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

RUN rm -rf /tmp/alwm && \
   mkdir -p /tmp/alwm && \
   wget -P /tmp/alwm https://afterlogic.org/download/webmail_php.zip && \
   unzip -q /tmp/alwm/webmail_php.zip -d /tmp/alwm/

RUN rm -rf /var/www/html && \
    mkdir -p /var/www/html && \
    cp -r /tmp/alwm/* /var/www/html && \
    chown www-data.www-data -R /var/www/html && \
    chmod 0777 -R /var/www/html/data
    
RUN rm -f /var/www/html/afterlogic.php
COPY afterlogic.php /var/www/html/afterlogic.php
RUN rm -rf /tmp/alwm

VOLUME ["/var/www/html", "/var/log/httpd", "/var/lib/mysql", "/var/log/mysql", "/etc/apache2"]

EXPOSE 80 3306

CMD ["/usr/sbin/run-lamp.sh"]
