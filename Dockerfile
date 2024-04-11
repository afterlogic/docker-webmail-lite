FROM alpine:3.16
LABEL Maintainer="Afterlogic Support <support@afterlogic.com>" \
      Description="Afterlogic WebMail Lite image for Docker - using Nginx, PHP-FPM 8, MySQL on Alpine Linux"

RUN apk --no-cache add php81 \
	php81-cli \
	php81-fpm \
	php81-fileinfo \
	php81-mysqli \
	php81-pdo \
	php81-pdo_mysql \
	php81-pdo_sqlite \
	php81-iconv \
	php81-mbstring \
	php81-curl \
	php81-dom \
	php81-xml \
	php81-gd \
	php81-exif \
	php81-zip \
	php81-xmlwriter \
	php81-xmlreader \
	nginx supervisor curl tzdata mysql-client

COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/fpm-pool.conf /etc/php81/php-fpm.d/www.conf
COPY config/php.ini /etc/php81/conf.d/custom.ini
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /var/www/html
RUN chown -R nobody.nobody /var/www/html && \
	chown -R nobody.nobody /run && \
	chown -R nobody.nobody /var/lib/nginx && \
	chown -R nobody.nobody /var/log/nginx

WORKDIR /var/www/html

RUN wget -P /tmp https://afterlogic.org/download/webmail_php.zip
RUN unzip -qq /tmp/webmail_php.zip -d /var/www/html
COPY afterlogic.php /var/www/html/afterlogic.php
RUN chown -R nobody.nobody /var/www/html/data
USER nobody
RUN php81 /var/www/html/afterlogic.php
EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1/fpm-ping
