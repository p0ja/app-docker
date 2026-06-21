FROM php:8.3-fpm-bookworm

ARG INSTALL_XDEBUG=false
ARG INSTALL_IMAGICK=false

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libzip-dev \
        unzip \
        git; \
    if [ "$INSTALL_IMAGICK" = "true" ]; then \
        apt-get install -y --no-install-recommends libmagickwand-dev; \
    fi; \
    rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp

RUN docker-php-ext-install -j "$(nproc)" \
        pdo \
        pdo_mysql \
        mysqli \
        bcmath \
        exif \
        gd \
        intl \
        zip

RUN set -eux; \
    docker-php-ext-enable opcache; \
    { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN set -eux; \
    if [ "$INSTALL_XDEBUG" = "true" ]; then \
        pecl install xdebug && docker-php-ext-enable xdebug; \
    fi; \
    if [ "$INSTALL_IMAGICK" = "true" ]; then \
        pecl install imagick-3.7.0 && docker-php-ext-enable imagick; \
    fi

RUN adduser --disabled-password --gecos "" app
USER app

WORKDIR /app

CMD ["php-fpm"]
