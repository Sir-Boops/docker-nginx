FROM alpine:3.7

ENV NGINX_VER="1.14.0"

RUN addgroup nginx && \
    adduser -H -D -G nginx nginx && \
    echo "nginx:`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -m sha256`" | chpasswd

RUN apk add -U --virtual deps \
        gcc g++ make pcre-dev zlib-dev \
        libressl-dev && \
    cd ~ && \
    wget http://nginx.org/download/nginx-$NGINX_VER.tar.gz && \
    wget https://github.com/yaoweibin/ngx_http_substitutions_filter_module/archive/v0.6.4.tar.gz && \
    wget https://github.com/AirisX/nginx_cookie_flag_module/archive/v1.1.0.tar.gz && \
    wget https://github.com/openresty/headers-more-nginx-module/archive/v0.33.tar.gz && \
    tar xf v0.6.4.tar.gz && \
    tar xf v1.1.0.tar.gz && \
    tar xf v0.33.tar.gz && \
    tar xf nginx-$NGINX_VER.tar.gz && \
    cd ~/nginx-$NGINX_VER/ && \
    ./configure --prefix=/opt/nginx \
        --add-module=../ngx_http_substitutions_filter_module-0.6.4 \
        --add-module=../nginx_cookie_flag_module-1.1.0 \
        --add-module=../headers-more-nginx-module-0.33 \
        --with-threads --with-http_ssl_module --with-http_v2_module \
        --with-http_gunzip_module && \
    make -j$(nproc) && \
    make install && \
    rm -rf ~/* && \
    apk del --purge deps && \
    apk add pcre libssl1.0 && \
    chown nginx:nginx -R /opt

CMD /opt/nginx/sbin/nginx -g 'daemon off; user nginx;'
