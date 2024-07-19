FROM kong:3.7.1

USER 0:0
RUN mkdir /home/kong && chown kong /home/kong
USER kong

COPY kong-middleman-plugin /kong-middleman-plugin
USER 0:0
RUN chown -R kong /kong-middleman-plugin
USER kong
WORKDIR /kong-middleman-plugin
RUN luarocks make *.rockspec --local

COPY kong-budget-plugin /kong-budget-plugin
USER 0:0
RUN chown -R kong /kong-budget-plugin
USER kong
WORKDIR /kong-budget-plugin
RUN luarocks make *.rockspec --local

COPY kong-mockup-plugin /kong-mockup-plugin
USER 0:0
RUN chown -R kong /kong-mockup-plugin
USER kong
WORKDIR /kong-mockup-plugin
RUN luarocks make *.rockspec --local

ENV KONG_NINGX_PROX_PROXY_BUFFERS 4 256k
ENV KONG_PLUGINS mockup,middleman,budget
