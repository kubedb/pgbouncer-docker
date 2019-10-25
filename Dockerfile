FROM alpine:3.8
ARG PGBOUNCER_VERSION=1.7.1
RUN apk add --no-cache libevent openssl c-ares \
    && apk add --no-cache --virtual .build-deps git build-base automake libtool m4 autoconf libevent-dev openssl-dev c-ares-dev \
    && wget https://pgbouncer.github.io/downloads/files/$PGBOUNCER_VERSION/pgbouncer-$PGBOUNCER_VERSION.tar.gz \
    && tar xzf pgbouncer-$PGBOUNCER_VERSION.tar.gz \
    && cd pgbouncer-$PGBOUNCER_VERSION \
    && ./autogen.sh \
    && ./configure --prefix=/usr/local --with-libevent=/usr/lib \
    && make \
    && make install \
    && cd .. \
    && rm -Rf pgbouncer-$PGBOUNCER_VERSION* \
    && wget -O fsloader https://github.com/appscode/fsloader/releases/download/0.1.0/fsloader-alpine-amd64 \
    && chmod +x fsloader \
    && mv fsloader /usr/bin/fsloader \
    && apk del .build-deps \
    && apk add --no-cache postgresql-client runit

ADD runit /runit
ADD fsloader /fsloader
ADD pgbouncer /pgbouncer

RUN chmod +x /fsloader/* \
    && chmod +x /pgbouncer/* \
    && chmod +x /runit/* \
    && mkdir -p /etc/service/fsloader \
    && mkdir -p /etc/service/pgbouncer \
    && ln -s /fsloader/run /etc/service/fsloader/run \
    && ln -s /pgbouncer/run /etc/service/pgbouncer/run

ENTRYPOINT ["/runit/run_runit.sh"]
