############################
# STAGE 1: Composer Build
############################
FROM composer:2 AS builder

WORKDIR /app

COPY composer.json composer.lock ./

RUN composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-scripts

COPY . .

############################
# STAGE 2: Runtime (Alpine)
############################
FROM php:8.2-fpm-alpine

# Install build + runtime deps
RUN apk add --no-cache \
    nginx \
    sqlite \
    sqlite-dev \
    libpng \
    libxml2 \
    oniguruma \
    zip \
    unzip \
    curl \
    pkgconf \
    $PHPIZE_DEPS

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_sqlite

# Remove build dependencies to reduce size
RUN apk del $PHPIZE_DEPS sqlite-dev pkgconf

# Nginx runtime setup
RUN mkdir -p /run/nginx

WORKDIR /var/www/html

# Copy app from builder
COPY --from=builder /app /var/www/html

# Remove default nginx config
RUN rm -f /etc/nginx/http.d/default.conf

# Copy Laravel nginx config
COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf

# Permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 storage bootstrap/cache

EXPOSE 80

CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]

