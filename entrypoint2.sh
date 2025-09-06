#!/bin/sh
set -e

echo ">>> Running Laravel container startup script..."

# --- 1. Ensure all required directories exist ---
mkdir -p /var/www/html/storage/logs
mkdir -p /var/www/html/storage/framework/{cache,sessions,views}
mkdir -p /var/www/html/bootstrap/cache

# --- 2. Fix ownership and permissions ---
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# --- 3. Run your seven commands ---

# 0: chown + chmod (already done above, optional repeat)
# docker exec -u 0 -it laravel-php sh -c "chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache"

# 1: mkdir + chown + chmod (already done above)
# 2: mkdir extra (already done above)
# 3: bootstrap/cache permissions (already done above)
# 4: artisan config:clear
php artisan config:clear || true
# 5: artisan cache:clear
php artisan cache:clear || true
# 6: artisan view:clear
php artisan view:clear || true

echo ">>> Startup tasks finished. Launching php-fpm..."

# --- 4. Start PHP-FPM ---
exec php-fpm
