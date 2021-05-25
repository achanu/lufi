FROM alpine:latest
LABEL maintainer="Alexandre Chanu <alexandre.chanu@gmail.com>"

ENV GID=991 \
    UID=991 \
    LUFI_DIR=/usr/lufi

RUN \
  apk add --update --no-cache --virtual .build-deps \
    build-base \
    libressl-dev \
    ca-certificates \
    git \
    tar \
    perl-dev \
    libidn-dev \
    wget \
  && \
  apk add --update --no-cache \
    libressl \
    perl \
    libidn \
    perl-crypt-rijndael \
    perl-test-manifest \
    perl-net-ssleay \
    tini \
    su-exec \
  && \
  echo | cpan && \
  cpan install CPAN && \
  cpan reload CPAN && \
  cpan install Carton && \
  git clone https://framagit.org/fiat-tux/hat-softwares/lufi.git ${LUFI_DIR} && \
  cd ${LUFI_DIR} && \
  git fetch --tags && \
  LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`) && \
  git checkout ${LATEST_TAG} && \
  carton install --deployment --without=test --without=swift-storage --without=ldap --without=postgresql --without=mysql && \
  apk del .build-deps && \
  rm -rf \
    /var/cache/apk/* \
    /root/.cpan* \
    ${LUFI_DIR}/local/cache/*

WORKDIR ${LUFI_DIR}

COPY startup /usr/local/bin/startup
COPY lufi.conf.template ${LUFI_DIR}/lufi.conf.template
RUN chmod -c +x /usr/local/bin/startup

CMD ["/usr/local/bin/startup"]

VOLUME ${LUFI_DIR}/data ${LUFI_DIR}/files
EXPOSE 8081
