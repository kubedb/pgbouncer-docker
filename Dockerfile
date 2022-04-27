FROM alpine

ARG TARGETOS
ARG TARGETARCH
ARG VERSION

RUN set -x \
    && apk add --no-cache libevent openssl c-ares ca-certificates \
    && apk add --no-cache --virtual .build-deps git build-base automake libtool m4 autoconf libevent-dev openssl-dev c-ares-dev \
    && wget -O pgbouncer.tar.gz https://pgbouncer.github.io/downloads/files/${VERSION}/pgbouncer-${VERSION}.tar.gz \
    && tar xzf pgbouncer.tar.gz \
    && cd pgbouncer-${VERSION} \
    && ./autogen.sh \
    && ./configure --prefix=/usr/local --with-libevent=/usr/lib \
    && make \
    && make install \
    && cd .. \
    && rm -rf pgbouncer-${VERSION} pgbouncer.tar.gz \
    && apk del .build-deps

RUN set -x \
    && apk add --no-cache postgresql-client runit

RUN set -x \
    && wget -O fsloader.tar.gz https://github.com/kubeops/fsloader/releases/download/v0.3.0/fsloader-${TARGETOS}-${TARGETARCH}.tar.gz \
    && tar xzf fsloader.tar.gz \
    && chmod +x fsloader-${TARGETOS}-${TARGETARCH} \
    && mv fsloader-${TARGETOS}-${TARGETARCH} /usr/local/bin/fsloader \
    && rm -rf LICENSE fsloader.tar.gz

ADD runit /runit
ADD fsloader /fsloader
ADD pgbouncer /pgbouncer

RUN chmod +x /fsloader/* \
    && chmod +x /pgbouncer/* \
    && chmod +x /runit/* \
    && mkdir -p /etc/service/fsloader \
    && mkdir -p /etc/service/pgbouncer \
    && chown -R postgres /fsloader/* /etc/service/fsloader /pgbouncer/* /etc/service/pgbouncer /runit/*

USER postgres

RUN ln -s /fsloader/run /etc/service/fsloader/run \
    && ln -s /pgbouncer/run /etc/service/pgbouncer/run

ENTRYPOINT ["/runit/run_runit.sh"]
