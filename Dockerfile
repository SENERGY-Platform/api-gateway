FROM kong:1.5.0

COPY kong-middleman-plugin /kong-middleman-plugin
WORKDIR /kong-middleman-plugin
RUN luarocks make *.rockspec

COPY kong-mockup-plugin /kong-mockup-plugin
WORKDIR /kong-mockup-plugin
RUN luarocks make *.rockspec

ENV KONG_NINGX_PROX_PROXY_BUFFERS 4 256k
ENV KONG_PLUGINS mockup,middleman
