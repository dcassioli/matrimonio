FROM ruby:alpine3.7

LABEL maintainer="dcassioli@gmail.com"

RUN apk add --no-cache \
  autoconf \
  automake \
  build-base \
  curl \
  git \
  gnupg \
  linux-headers \
  nasm \
  python \
  paxctl

# gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex \
  && for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
  ; do \
    ( gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" \
      || gpg --keyserver pgp.mit.edu --recv-keys "$key" \
      || gpg --keyserver keyserver.pgp.com --recv-keys "$key" ) \
  done

ENV NODE_VERSION=v8.11.2

# Download and build Node.js
RUN curl -o node-${NODE_VERSION}.tar.gz -sSL https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}.tar.gz \
  && curl -o SHASUMS256.txt.asc -sSL https://nodejs.org/dist/${NODE_VERSION}/SHASUMS256.txt.asc \
  && gpg --verify SHASUMS256.txt.asc \
  && grep node-${NODE_VERSION}.tar.gz SHASUMS256.txt.asc | sha256sum -c - \
  && tar -zxf node-${NODE_VERSION}.tar.gz \
  && cd node-${NODE_VERSION} \
  && export GYP_DEFINES="linux_use_gold_flags=0" \
  && ./configure --prefix=/usr ${CONFIG_FLAGS} \
  && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
  && make -j${NPROC} -C out mksnapshot BUILDTYPE=Release \
  && paxctl -cm out/Release/mksnapshot \
  && make -j${NPROC} \
  && make install \
  && paxctl -cm /usr/bin/node

# Install npm
RUN cd / \
  && npm install -g npm@latest \
  && find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf;

# Cleanup Node.js build
RUN rm -rf \
  /node-${NODE_VERSION}.tar.gz \
  /SHASUMS256.txt.asc \
  /node-${NODE_VERSION} \
  /root/.npm \
  /root/.node-gyp

RUN gem install bundler

EXPOSE 3000 3001

RUN apk add --update --no-cache \
  ca-certificates \
  openssh-client \
  wget \
  && update-ca-certificates

# Security fix for CVE-2016-0777 and CVE-2016-0778
RUN echo -e 'Host *\nUseRoaming no' >> /etc/ssh/ssh_config \
  && mkdir ~/.ssh

# Initialize GitHub host key
RUN ssh-keyscan github.com >> /etc/ssh/ssh_known_hosts

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 \
  && chmod +x /usr/local/bin/dumb-init

RUN apk del \
    ca-certificates \
    wget \
  && rm -rf /var/cache/apk/*

# Force the use of https: instead of git:
RUN git config --global url."https://".insteadOf git://

RUN npm install -g gulp-cli

WORKDIR /usr/app

COPY package.json package.json
COPY Gemfile Gemfile

RUN npm install \
  && bundle install \
  && npm cache clean --force \
  && rm -f package.json Gemfile Gemfile.lock

RUN mkdir -p /root/.ssh
COPY id_rsa_cassio_pk_1 /root/.ssh/id_rsa

# Configure Git
RUN \
  git config --global user.email "dcassioli@gmail.com" \
  && git config --global user.name "Davide Cassioli"

ENTRYPOINT [ "dumb-init", "gulp" ]
