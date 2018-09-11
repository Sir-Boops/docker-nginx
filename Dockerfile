FROM alpine:3.8

# NGINX and OpenSSL versions
ENV NGINX_VER="1.15.3"
ENV SSL_VER="OpenSSL_1_1_1"

# NGINX module versions
ENV SUB_VER="0.6.4"
ENV COOKIE_VER="1.1.0"
ENV HEADERS_VER="0.33"

RUN addgroup nginx && \
    adduser -H -D -G nginx nginx && \
    echo "nginx:`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -m sha256`" | chpasswd

RUN apk add -U --virtual deps \
    gcc g++ make pcre-dev zlib-dev \
    perl linux-headers && \
  cd ~ && \
  wget http://nginx.org/download/nginx-$NGINX_VER.tar.gz && \
  wget https://github.com/yaoweibin/ngx_http_substitutions_filter_module/archive/v$SUB_VER.tar.gz && \
  wget https://github.com/AirisX/nginx_cookie_flag_module/archive/v$COOKIE_VER.tar.gz && \
  wget https://github.com/openresty/headers-more-nginx-module/archive/v$HEADERS_VER.tar.gz && \
  wget https://github.com/openssl/openssl/archive/$SSL_VER.tar.gz && \
  cd ~ && \
  tar xf nginx-$NGINX_VER.tar.gz && \
  tar xf v$SUB_VER.tar.gz && \
  tar xf v$COOKIE_VER.tar.gz && \
	tar xf v$HEADERS_VER.tar.gz && \
  tar xf $SSL_VER.tar.gz && \
  cd ~/nginx-$NGINX_VER/ && \
  ./configure --prefix=/opt/nginx \
    --add-module=../ngx_http_substitutions_filter_module-$SUB_VER \
    --add-module=../nginx_cookie_flag_module-$COOKIE_VER \
		--add-module=../headers-more-nginx-module-$HEADERS_VER \
    --with-openssl=../openssl-$SSL_VER --with-openssl-opt=enable-tls1_3 \
    --with-threads --with-http_ssl_module --with-http_v2_module \
    --with-http_gunzip_module && \
  make -j$(nproc) && \
  make install && \
  rm -rf ~/* && \
  apk del --purge deps && \
  apk add pcre && \
  chown nginx:nginx -R /opt

CMD /opt/nginx/sbin/nginx -g 'daemon off; user nginx;'
