FROM nginx:mainline-alpine

LABEL maintainer="Maciej Iwanowicz <tibiaczek9@proton.me>" \
      description="Lightweight IVFi-PHP container with latest Nginx mainline branch & PHP 8.2 based on Alpine Linux."

RUN apk update
RUN apk add --no-cache \
    bash bash-completion supervisor tzdata shadow \
    php82 php82-fpm php82-opcache

# Environment variables
ENV DUID=1500
ENV DGID=1500

# Configuration files
COPY config/ivfi.conf /etc/nginx/conf.d/ivfi.conf
COPY config/php_timezone.ini /etc/php82/conf.d/00_timezone.ini
COPY config/php_enable_jit.ini /etc/php82/conf.d/00_jit.ini
COPY config/php_set_memory_limit.ini /etc/php82/conf.d/00_memlimit.ini
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy IVFi
COPY config/ivfi /usr/share/ivfi

# Configure Nginx server
RUN sed --in-place=.bak 's/worker_processes  1/worker_processes  auto/g' /etc/nginx/nginx.conf
RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak

# Shell init script
ADD config/init.sh /

RUN chmod a+x /init.sh

EXPOSE 80

VOLUME [ "/config", "/ivfi" ]

ENTRYPOINT [ "/init.sh" ]