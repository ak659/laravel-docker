#!/bin/sh
set -e

echo ">>> Running Laravel container startup script..."

# Wait for MySQL to be ready
echo ">>> Waiting for MySQL at ${DB_HOST}:${DB_PORT:-3306}..."
until php -r "
    try {
        new PDO(
            'mysql:host=' . getenv('DB_HOST') . ';port=' . (getenv('DB_PORT') ?: 3306),
            getenv('DB_USERNAME'),
            getenv('DB_PASSWORD')
        );
        exit(0);
    } catch (Exception \$e) {
        exit(1);
    }
"; do
    sleep 2
done

echo ">>> MySQL is ready!"

# Ensure .env exists
if [ ! -f /var/www/html/.env ]; then
    echo ">>> No .env file found. Creating one from .env.example..."
    cp /var/www/html/.env.example /var/www/html/.env
    chown www-data:www-data /var/www/html/.env
fi

# Ensure required directories exist
mkdir -p /var/www/html/storage/logs
mkdir -p /var/www/html/storage/framework/cache
mkdir -p /var/www/html/storage/framework/sessions
mkdir -p /var/www/html/storage/framework/views
mkdir -p /var/www/html/bootstrap/cache

# Fix ownership and permissions
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Run Laravel optimizations
php artisan config:clear || true
php artisan cache:clear || true
php artisan route:clear || true
php artisan view:clear || true
php artisan migrate --force || true

echo ">>> Startup tasks finished. Launching php-fpm..."
exec php-fpm