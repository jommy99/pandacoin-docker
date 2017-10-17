FROM ubuntu:trusty

RUN useradd -r pandacoin

ENV GOSU_VERSION=1.9

RUN apt-get update && apt-get install -y \
      curl \
      gnupg \
      wget \
      unzip \
      build-essential \
      libssl-dev \
      libdb++-dev \
      libboost-all-dev \
      libminiupnpc-dev \
      libdb++-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN set -ex \
  && for key in \
    B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  ; do \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ; \
  done

RUN curl -o /usr/local/bin/gosu -fSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture) \
    && curl -o /usr/local/bin/gosu.asc -fSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture).asc \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

RUN cd /tmp \
    && wget https://github.com/DigitalPandacoin/pandacoin/archive/master.zip \
    && unzip master.zip \
    && cd pandacoin-master/src \
    && chmod +x leveldb/build_detect_platform \
    && make -j9 -f makefile.unix \
    && strip pandacoind \
    && cp pandacoind /usr/local/bin/ \
    && rm -rf /tmp/pandacoin-master master.zip

ENV PANDACOIN_DATA=/home/pandacoin/.pandacoin

VOLUME ["/home/pandacoin/.pandacoin"]

COPY docker-entrypoint.sh /entrypoint.sh
COPY pandacoin.conf /home/pandacoin/.pandacoin/

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 22444 22445

CMD ["pandacoind"]
