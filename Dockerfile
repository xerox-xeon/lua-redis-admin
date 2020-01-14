FROM openresty/openresty:centos
RUN /usr/local/openresty/bin/opm get openresty/lua-resty-redis && \
    /usr/local/openresty/bin/opm get anjia0532/lua-resty-redis-util && \
    /usr/local/openresty/bin/opm get sumory/lor