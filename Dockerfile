FROM php:8.3.20-fpm-alpine3.20

RUN apk add --no-cache \
    git \
    curl \
    mariadb-client \
    && docker-php-ext-install mysqli
