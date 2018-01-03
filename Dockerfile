FROM ubuntu:trusty

ENV PUBLISHER=DigitalPandacoin \
    PROJECT=pandacoin \
    COMMIT=e2b4390a9f595f140c81e6db29fcb42d4a6270c0 \
    PANDACOIN_DATA=/home/pandacoin/.pandacoin

RUN useradd -r pandacoin

RUN apt-get update && apt-get install -y \
      wget \
      build-essential \
      libssl-dev \
      libdb++-dev \
      libboost-all-dev \
      libminiupnpc-dev \
    && cd /tmp \
    && wget -O - https://github.com/${PUBLISHER}/${PROJECT}/archive/${COMMIT}.tar.gz | tar -xz \
    && cd ${PROJECT}-${COMMIT}/src \
    && chmod +x leveldb/build_detect_platform \
    && make -j$(nproc) -f makefile.unix \
    && strip pandacoind \
    && cp pandacoind /usr/local/bin/ \
    && apt-get remove --purge -y \
      wget \
      build-essential \
      $(apt-mark showauto) \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV GOSU_VERSION=1.9

RUN apt-get update && apt-get install -y curl \
    && for key in \
         B42F6819007F00F88E364FD4036A9C25BF357DD4 \
       ; do \
         gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
         gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
         gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
         gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ; \
       done \
    && curl -o /usr/local/bin/gosu -fSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture) \
    && curl -o /usr/local/bin/gosu.asc -fSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture).asc \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && apt-get remove --purge -y curl $(apt-mark showauto) \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.gnupg

VOLUME ["/home/pandacoin/.pandacoin"]

COPY docker-entrypoint.sh /entrypoint.sh
COPY pandacoin.conf /home/pandacoin/.pandacoin/

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 22444 22445

CMD ["pandacoind"]
