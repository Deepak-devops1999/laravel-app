############################
# STAGE 1: Composer Build
############################
FROM composer:2 AS builder

WORKDIR /app

# Copy full application so artisan exists
COPY . .

# Install dependencies WITHOUT running Laravel scripts
RUN composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-scripts


############################
# STAGE 2: Runtime (PHP-FPM + Nginx)
############################
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    sqlite3 \
    libsqlite3-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip unzip curl \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_sqlite

# Set working directory
WORKDIR /var/www/html

# Copy application from builder stage
COPY --from=builder /app /var/www/html

# Copy Nginx configuration
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Fix permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose HTTP port
EXPOSE 80

# Start PHP-FPM and Nginx
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]

