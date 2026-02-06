############################
# STAGE 1: Composer Build
############################
FROM composer:2 AS builder

WORKDIR /app
COPY . .

RUN composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-scripts


############################
# STAGE 2: Runtime
############################
FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    nginx \
    sqlite3 \
    libsqlite3-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip unzip curl \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo pdo_sqlite

WORKDIR /var/www/html

COPY --from=builder /app /var/www/html

# 🔥 REMOVE DEFAULT NGINX SITE (THIS FIXES THE ISSUE)
RUN rm -f /etc/nginx/sites-enabled/default

# COPY OUR LARAVEL NGINX CONFIG
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80

CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]

