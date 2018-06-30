FROM alpine:3.7

ENV NGINX_VER="1.15.0"

RUN addgroup nginx && \
    adduser -H -D -G nginx nginx && \
    echo "nginx:`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -m sha256`" | chpasswd

RUN apk add -U --virtual deps \
        gcc g++ make pcre-dev zlib-dev \
        libressl-dev && \
    cd ~ && \
    wget http://nginx.org/download/nginx-$NGINX_VER.tar.gz && \
    tar xf nginx-$NGINX_VER.tar.gz && \
    cd ~/nginx-$NGINX_VER/ && \
    ./configure --prefix=/opt/nginx \
        --with-threads --with-http_ssl_module
        --with-http_v2_module \
        --with-http_gunzip_module && \
    make -j$(nproc) && \
    make install && \
    rm -rf ~/* && \
    apk del --purge deps && \
    apk add pcre libssl1.0 && \
    chown nginx:nginx -R /opt

CMD /opt/nginx/sbin/nginx -g 'daemon off; user nginx;'
