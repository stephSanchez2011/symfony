ARG VERSION

FROM php:${VERSION}-fpm-alpine

## Install system dependencies
RUN apk update && \
    apk add --no-cache --virtual dev-deps git autoconf gcc g++ make && \
    apk add --no-cache zlib-dev libzip-dev postgresql-dev libpng-dev

## Install php extensions
RUN pecl install xdebug && \
    docker-php-ext-enable xdebug && \
    docker-php-ext-install pdo_pgsql zip gd calendar

## Copy php default configuration
COPY default.ini /usr/local/etc/php/conf.d/default.ini

WORKDIR /back

## Install composer
RUN wget https://getcomposer.org/installer && \
    php installer --install-dir=/usr/local/bin/ --filename=composer && \
    rm installer
