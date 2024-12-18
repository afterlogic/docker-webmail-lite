FROM alpine:3.19
LABEL Maintainer="Afterlogic Support <support@afterlogic.com>" \
      Description="Afterlogic WebMail Lite image for Docker - using Nginx, PHP-FPM 8, MySQL on Alpine Linux"

RUN apk --no-cache add php83 \
	php83-cli \
	php83-fpm \
	php83-fileinfo \
	php83-mysqli \
	php83-pdo \
	php83-pdo_mysql \
	php83-pdo_sqlite \
	php83-iconv \
	php83-mbstring \
	php83-curl \
	php83-dom \
	php83-xml \
	php83-gd \
	php83-exif \
	php83-zip \
	php83-xmlwriter \
	php83-xmlreader \
	nginx supervisor curl tzdata mysql-client

COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/fpm-pool.conf /etc/php83/php-fpm.d/www.conf
COPY config/php.ini /etc/php83/conf.d/custom.ini
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
RUN php83 /var/www/html/afterlogic.php
EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1/fpm-ping
