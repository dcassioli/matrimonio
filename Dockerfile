FROM ferrarimarco/open-development-environment-jekyll:1.2.0

LABEL maintainer="dcassioli@gmail.com"

RUN apk add --no-cache --update \
  autoconf \
  automake \
  build-base \
  ca-certificates \
  git \
  nasm \
  openssh-client \
  wget \
    && update-ca-certificates \
    && echo -e 'Host *\nUseRoaming no' >> /etc/ssh/ssh_config \
    && ssh-keyscan github.com >> /etc/ssh/ssh_known_hosts \
    && wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 \
    && chmod +x /usr/local/bin/dumb-init \
    && apk del wget


# Force the use of https: instead of git:
RUN git config --global url."https://".insteadOf git://

RUN npm install -g gulp-cli

WORKDIR /usr/app

COPY package.json package.json
RUN npm install \
  && npm cache clean --force

COPY Gemfile Gemfile
RUN bundle install

RUN mkdir -p /root/.ssh
COPY id_rsa_cassio_pk_1 /root/.ssh/id_rsa

# Configure Git
RUN \
  git config --global user.email "dcassioli@gmail.com" \
  && git config --global user.name "Davide Cassioli"

ENTRYPOINT [ "dumb-init", "gulp" ]

EXPOSE 3000 3001
