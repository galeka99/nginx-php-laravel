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
    php82 \
    php82-bcmath \
    php82-ctype \
    php82-curl \
    php82-dom \
    php82-fpm \
    php82-fileinfo \
    php82-gd \
    php82-iconv \
    php82-intl \
    php82-json \
    php82-mbstring \
    php82-mysqlnd \
    php82-opcache \
    php82-openssl \
    php82-pdo \
    php82-pdo_mysql \
    php82-pdo_pgsql \
    php82-pdo_sqlite \
    php82-phar \
    php82-posix \
    php82-session \
    php82-simplexml \
    php82-soap \
    php82-tokenizer \
    php82-xml \
    php82-xmlreader \
    php82-xmlwriter \
    php82-zip

# INSTALL BASH
RUN apk add bash && sed -i 's/bin\/ash/bin\/bash/g' /etc/passwd

# INSTALL COMPOSER
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# CONFIGURE SUPERVISOR
RUN mkdir -p /etc/supervisor.d/
COPY .docker/supervisord.ini /etc/supervisor.d/supervisord.ini

# CONFIGURE PHP
RUN mkdir -p /run/php/ && touch /run/php/php8.2-fpm.pid

COPY .docker/php.ini-production /etc/php82/php.ini
COPY .docker/php-fpm.conf /etc/php82/php-fpm.conf

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