FROM registry.access.redhat.com/ubi8/ubi-minimal:latest
ARG VERSION=1.16.0
ENV USER_ID=1001

RUN microdnf install -y make openssl-devel libevent libevent-devel pkgconfig automake autoconf gcc curl glibc-devel tar gzip && \

curl -sLo /tmp/pgbouncer-$VERSION.tar.gz https://pgbouncer.github.io/downloads/files/$VERSION/pgbouncer-$VERSION.tar.gz && \

tar xzvf /tmp/pgbouncer-1.16.0.tar.gz -C /opt && \

mkdir /etc/pgbouncer && \

cd /opt/pgbouncer-$VERSION && ./configure && \

make && make install && \

cp etc/pgbouncer.ini /etc/pgbouncer && \

cd / && rm -rf /opt/pgbouncer-$VERSION

WORKDIR /
ADD entrypoint.sh .

VOLUME ["/pgconf"]
EXPOSE 5432
ENTRYPOINT ["/entrypoint.sh"]
