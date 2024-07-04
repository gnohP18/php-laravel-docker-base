#!/bin/bash

nginx

APP_CODE_PATH_CONTAINER="/var/www/html"

chown -R www-data:www-data ${APP_CODE_PATH_CONTAINER}

find ${APP_CODE_PATH_CONTAINER} -type f -exec chmod 644 {} \;
find ${APP_CODE_PATH_CONTAINER} -type d -exec chmod 755 {} \;

chgrp -R www-data storage bootstrap/cache
chmod -R ug+rwx storage bootstrap/cache
# CMD ["usermod -a -G www-data www-data"]
