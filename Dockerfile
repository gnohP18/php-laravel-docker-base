ARG APP_CODE_PATH_CONTAINER=${APP_CODE_PATH_CONTAINER}
ARG PHP_VERSION=${PHP_VERSION}
ARG PHP_UPSTREAM_PORT=${PHP_UPSTREAM_PORT}
ARG NODE_VERSION=${NODE_VERSION}

FROM php:${PHP_VERSION}-fpm

# Use it for PHP 5.x
# RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list

RUN apt-get update && apt-get install -y wget gnupg g++ locales unzip dialog apt-utils git && apt-get clean

# Install node
RUN curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" | bash -
RUN apt-get update && apt-get install -y nodejs && apt-get clean

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# libpng-dev needed by "gd" extension
# libzip-dev needed by "zip" extension
# libicu-dev for intl extension
# libpg-dev for connection to postgres database
# autoconf needed by "redis" extension
# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    npm \
    yarn \
    nano \
    supervisor

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

COPY ./supervisor/project.conf /etc/supervisor/conf.d/project.conf
COPY ./php/php.ini /usr/local/etc/php/php.ini

# RUN npm install

# Copy existing application directory permissions
# Add user for laravel application
# RUN groupadd -g 1000 www
# RUN useradd -u 1000 -ms /bin/bash -g www www

# ADD . /var/www
# RUN chown -R www-data:www-data ${APP_CODE_PATH_CONTAINER}

# RUN find ${APP_CODE_PATH_CONTAINER} -type f -exec chmod 644 {} \;
# RUN find ${APP_CODE_PATH_CONTAINER} -type d -exec chmod 755 {} \;

WORKDIR ${APP_CODE_PATH_CONTAINER}

# RUN mkdir storage
# RUN mkdir bootstrap
# RUN mkdir bootstrap/cache

# RUN chgrp -R www-data storage bootstrap/cache
# RUN chmod -R ug+rwx storage bootstrap/cache

RUN echo "* * * * * root php ${APP_CODE_PATH_CONTAINER}/artisan schedule:run >> /var/log/cron.log 2>&1" >> /etc/crontab

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

USER root

# Expose port 9000 and start php-fpm server
EXPOSE ${PHP_UPSTREAM_PORT}
CMD ["php-fpm"]
