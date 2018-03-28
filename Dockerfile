FROM alpine:3.7

ENV NGINX_VER="1.13.10"

RUN addgroup nginx && \
	adduser -H -D -G nginx nginx && \
	echo "nginx:`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -m sha256`" | chpasswd

RUN apk add -U --virtual deps \
		gcc g++ make pcre-dev zlib-dev \
		openssl-dev && \
	cd ~ && \
	wget http://nginx.org/download/nginx-$NGINX_VER.tar.gz && \
	wget https://github.com/yaoweibin/ngx_http_substitutions_filter_module/archive/v0.6.4.tar.gz && \
	tar xf v0.6.4.tar.gz && \
	tar xf nginx-$NGINX_VER.tar.gz && \
	cd ~/nginx-$NGINX_VER/ && \
	./configure --prefix=/opt/nginx \
		--add-module=../ngx_http_substitutions_filter_module-0.6.4 \
		--with-threads --with-http_ssl_module --with-http_v2_module \
		--with-http_gunzip_module && \
	make -j$(nproc) && \
	make install && \
	rm -rf ~/* && \
	apk del --purge deps && \
	apk add pcre libssl1.0
