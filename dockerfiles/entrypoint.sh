#!/bin/sh
set -e

echo ">>> Running Laravel container startup script..."

# --- 1. Ensure required directories exist ---
if [ "$(id -u)" = "0" ]; then
    echo ">>> Creating storage and bootstrap/cache directories..."
    mkdir -p /var/www/html/storage/logs
    mkdir -p /var/www/html/storage/framework/cache
    mkdir -p /var/www/html/storage/framework/sessions
    mkdir -p /var/www/html/storage/framework/views
    mkdir -p /var/www/html/bootstrap/cache

    echo ">>> Fixing permissions..."
    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache
else
    echo ">>> Skipping chown/chmod (not running as root)..."
fi

# --- 2. Wait for MySQL TCP port only ---
echo ">>> Waiting for MySQL at $DB_HOST:$DB_PORT..."
until nc -z "$DB_HOST" "$DB_PORT"; do
  echo "MySQL not ready yet..."
  sleep 2
done
echo ">>> MySQL is ready!"

# --- 3. Laravel cache & migration setup ---
echo ">>> Clearing caches..."
php artisan config:clear || true
php artisan cache:clear || true
php artisan view:clear || true
php artisan route:clear || true

# Ensure cache table migration exists
if [ ! "$(ls database/migrations/*_create_cache_table.php 2>/dev/null)" ]; then
    echo ">>> Creating cache table migration..."
    php artisan cache:table || true
fi

# Run migrations
echo ">>> Running migrations..."
php artisan migrate --force || true

# --- 4. Optimize Laravel for production ---
echo ">>> Optimizing Laravel..."
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

# --- 5. Restart queues ---
php artisan queue:restart || true

# --- 6. Start PHP-FPM ---
echo ">>> Startup tasks finished. Launching php-fpm..."
exec php-fpm
