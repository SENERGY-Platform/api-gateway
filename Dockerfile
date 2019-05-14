FROM alpine:3.6
RUN echo "http://dl-4.alpinelinux.org/alpine/v3.3/main" >> /etc/apk/repositories;

ENV KONG_VERSION 1.1.2
ENV KONG_SHA256 6b9f5ae87fc63202ef8bda5f34ebe7b66b9c13abfe7a067b5edab8a05a60a2ef

RUN apk add --no-cache --virtual .build-deps wget tar ca-certificates \
	&& wget -O kong.tar.gz "https://bintray.com/kong/kong-community-edition-alpine-tar/download_file?file_path=kong-community-edition-$KONG_VERSION.apk.tar.gz" \
	&& apk add --no-cache libgcc openssl pcre perl tzdata \
	&& echo "$KONG_SHA256 *kong.tar.gz" | sha256sum -c - \
	&& tar -xzf kong.tar.gz -C /tmp \
	&& rm -f kong.tar.gz \
	&& cp -R /tmp/usr / \
	&& rm -rf /tmp/usr \
	&& cp -R /tmp/etc / \
	&& rm -rf /tmp/etc \
	&& apk del .build-deps

COPY kong-middleman-plugin- /kong-middleman-plugin
WORKDIR /kong-middleman-plugin
RUN luarocks make *.rockspec

COPY kong-mockup-plugin /kong-mockup-plugin
WORKDIR /kong-mockup-plugin
RUN luarocks make *.rockspec

COPY docker-entrypoint.sh /docker-entrypoint.sh

COPY nginx.conf /nginx.conf

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGTERM

CMD ["/usr/local/openresty/nginx/sbin/nginx", "-c", "/usr/local/kong/nginx.conf", "-p", "/usr/local/kong/"]