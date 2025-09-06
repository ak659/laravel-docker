FROM php:8.2-fpm-alpine

# Set working directory early
WORKDIR /var/www/html

# Install system dependencies & build tools
RUN apk update && apk add --no-cache \
    bash \
    git \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    oniguruma-dev \
    icu-dev \
    libxml2-dev \
    zip \
    unzip \
    autoconf \
    g++ \
    make \
    build-base

# Configure GD with jpeg and freetype support
RUN docker-php-ext-configure gd \
        --with-freetype=/usr/include/ \
        --with-jpeg=/usr/include/ \
    && docker-php-ext-install gd

# Install PHP extensions required by Laravel
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    mbstring \
    bcmath \
    exif \
    pcntl \
    intl

# Install Composer (latest stable)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Clean up build dependencies (optional)
RUN apk del g++ make autoconf build-base

# Default user
USER www-data