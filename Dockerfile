FROM alpine:latest

WORKDIR /var/www/html

# SET TIMEZONE
RUN echo "UTC" > /etc/timezone

# INSTALL DEPENDENCIES
RUN apk update && apk add --no-cache \
    curl \
    nginx \
    openrc \
    libpng-dev \
    libxml2-dev \
    supervisor \
    zip \
    unzip \
    php81 \
    php81-bcmath \
    php81-ctype \
    php81-curl \
    php81-dom \
    php81-fpm \
    php81-fileinfo \
    php81-gd \
    php81-iconv \
    php81-intl \
    php81-json \
    php81-mbstring \
    php81-mysqlnd \
    php81-opcache \
    php81-openssl \
    php81-pdo \
    php81-pdo_mysql \
    php81-pdo_pgsql \
    php81-pdo_sqlite \
    php81-phar \
    php81-posix \
    php81-session \
    php81-simplexml \
    php81-soap \
    php81-tokenizer \
    php81-xml \
    php81-xmlreader \
    php81-xmlwriter \
    php81-zip

# INSTALL BASH
RUN apk add bash && sed -i 's/bin\/ash/bin\/bash/g' /etc/passwd

# INSTALL COMPOSER
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
    
# CONFIGURE SUPERVISOR
RUN mkdir -p /etc/supervisor.d/
COPY .docker/supervisord.ini /etc/supervisor.d/supervisord.ini

# CONFIGURE PHP
RUN mkdir -p /run/php/ && touch /run/php/php8.1-fpm.pid

COPY .docker/php.ini-production /etc/php81/php.ini
COPY .docker/php-fpm.conf /etc/php81/php-fpm.conf

# CONFIGURE NGINX
COPY .docker/nginx.conf /etc/nginx/
COPY .docker/nginx-laravel.conf /etc/nginx/http.d/default.conf

# CONFIGURE NGINX TEMP PATH
RUN mkdir /tmp/nginx
RUN chown nobody:nobody -R /tmp/nginx
RUN chmod 755 -R /tmp/nginx

RUN mkdir -p /run/nginx/ && touch /run/nginx/nginx.pid
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

# CREATE DEFAULT PAGE
RUN mkdir -p /var/www/html/public && echo "<?php phpinfo(); ?>" >> /var/www/html/public/index.php

# RUN SUPERVISOR
CMD ["supervisord", "-c", "/etc/supervisor.d/supervisord.ini", "-l", "/etc/supervisor.d/supervisord.log", "-j", "/etc/supervisor.d/supervisord.pid"]

# EXPOSE
EXPOSE 80