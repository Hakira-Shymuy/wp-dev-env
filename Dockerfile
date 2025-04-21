FROM php:8.3.20-fpm-alpine3.20

RUN apk add --no-cache \
    # Basic system tools
    git curl mariadb-client \
    # PHP extensions dependencies
    libzip-dev \
    libjpeg-turbo-dev libpng-dev freetype-dev libwebp-dev \
    icu-dev libxml2-dev oniguruma-dev zlib-dev \
    # Install extensions
    && docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp \
    && docker-php-ext-install \
    gd mysqli pdo pdo_mysql zip exif intl
