##################################
# STAGE 1: Composer Dependencies
##################################
FROM composer:2 AS composer

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-scripts

COPY . .

##################################
# STAGE 2: Frontend Build (Vite)
##################################
FROM node:20-alpine AS nodebuilder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

COPY resources resources
COPY vite.config.js .

RUN npm run build

##################################
# STAGE 3: Runtime (PHP + Nginx)
##################################
FROM php:8.2-fpm-alpine

# Install runtime + build deps
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

# PHP extensions
RUN docker-php-ext-install pdo pdo_sqlite

# Remove build deps
RUN apk del $PHPIZE_DEPS sqlite-dev pkgconf

# Nginx runtime
RUN mkdir -p /run/nginx

WORKDIR /var/www/html

# Copy Laravel app
COPY --from=composer /app /var/www/html

# Copy built frontend assets
COPY --from=nodebuilder /app/public/build /var/www/html/public/build

# Remove default nginx config
RUN rm -f /etc/nginx/http.d/default.conf

# Copy Laravel nginx config
COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf

# Permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 storage bootstrap/cache

EXPOSE 80

CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]

