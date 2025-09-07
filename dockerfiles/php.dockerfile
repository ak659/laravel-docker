# Use official lightweight PHP image
FROM php:8.2-fpm-alpine

# Install system utilities
RUN apk add --no-cache \
    bash \
    git \
    curl \
    zip \
    unzip \
    icu-libs \
    libpng \
    libjpeg-turbo \
    freetype \
    libxml2

# Download and enable extension installer
RUN curl -sSLf \
      https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
      -o /usr/local/bin/install-php-extensions \
    && chmod +x /usr/local/bin/install-php-extensions

# Install all required PHP extensions in one go
RUN install-php-extensions \
    pdo_mysql \
    mbstring \
    bcmath \
    exif \
    pcntl \
    intl \
    gd

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy custom entrypoint (make sure this file exists in ./dockerfiles/)
COPY dockerfiles/entrypoint.sh /usr/local/bin/entrypoint.sh

# Fix permissions BEFORE switching to non-root user
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set working directory
WORKDIR /var/www/html

# Switch to non-root user
USER www-data

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command (if entrypoint doesn’t override it)
CMD ["php-fpm"]