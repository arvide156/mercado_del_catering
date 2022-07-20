FROM php:8.1-fpm-alpine

RUN apk add --no-cache \
    nginx \
    wget \
    postgresql-dev \
    zip \
    unzip \
    dos2unix \
    supervisor \
    libpng-dev \
    libzip-dev \
    freetype-dev \
    $PHPIZE_DEPS \
    libjpeg-turbo-dev

RUN mkdir -p /run/nginx

COPY docker/nginx.conf /etc/nginx/nginx.conf

RUN docker-php-ext-install \
    gd \
    pcntl \
    bcmath

RUN mkdir -p /app
COPY . /app
COPY ./src /app

RUN docker-php-ext-configure pgsql -with-pgsql=/urs/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql

EXPOSE 8080

RUN sh -c "wget http://getcomposer.org/composer.phar && chmod a+x composer.phar && mv composer.phar /usr/local/bin/composer"
RUN cd /app && \
    /usr/local/bin/composer install --no-interaction --optimize-autoloader --no-dev

RUN cd /app && \
    /usr/local/bin/composer update
RUN cd /app && \
    /usr/local/bin/composer dumpautoload

RUN chown -R www-data: /app

CMD sh /app/docker/startup.sh