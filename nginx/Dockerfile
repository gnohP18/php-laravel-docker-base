FROM nginx:alpine

ARG APP_CODE_PATH_CONTAINER=${APP_CODE_PATH_CONTAINER}

COPY nginx.conf /etc/nginx/

WORKDIR /var/www

RUN apk update \
    && apk upgrade \
    && apk --update add logrotate \
    && apk add --no-cache openssl \
    && apk add --no-cache bash

RUN apk add --no-cache curl

RUN set -x ; \
    addgroup -g 82 -S www-data ; \
    adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1

ADD . /var/www

ARG PHP_UPSTREAM_CONTAINER=${PHP_UPSTREAM_CONTAINER}
ARG PHP_UPSTREAM_PORT=${PHP_UPSTREAM_PORT}

# Create 'messages' file used from 'logrotate'
RUN touch /var/log/messages

# Copy 'logrotate' config file
COPY logrotate/nginx /etc/logrotate.d/

# Set upstream conf and remove the default conf
RUN echo "upstream php-upstream { server ${PHP_UPSTREAM_CONTAINER}:${PHP_UPSTREAM_PORT}; }" > /etc/nginx/conf.d/upstream.conf \
    && rm /etc/nginx/conf.d/default.conf

WORKDIR ${APP_CODE_PATH_CONTAINER}

# ADD ./startup.sh /opt/startup.sh
# RUN sed -i 's/\r//g' /opt/startup.sh
# CMD ["/bin/bash", "/opt/startup.sh"]

EXPOSE 80 81 443
