FROM alpine:3.8
ARG PGBOUNCER_VERSION=1.9.0
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
    && apk del .build-deps
RUN apk add --no-cache postgresql-client

ADD runit /runit
ADD fsloader /fsloader
RUN chmod +x /fsloader/*
ADD pgbouncer /pgbouncer
RUN chmod +x /pgbouncer/*
RUN chmod +x /runit/*
RUN mkdir -p /etc/service/fsloader
RUN mkdir -p /etc/service/pgbouncer
RUN ln -s /fsloader/run /etc/service/fsloader/run
RUN ln -s /pgbouncer/run /etc/service/pgbouncer/run
RUN apk --update add runit
RUN mv /fsloader/fsloader /usr/bin/fsloader
ENTRYPOINT ["./runit/run_runit.sh"]
