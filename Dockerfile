FROM mono:slim

ARG S6_RELEASE
ENV HS_HOME=/opt/homeseer
ENV HOMESEER_VERSION=4_1_10_0

RUN apt update && \ 
    apt install -y \
    jq \
    sed \
    chromium \
    flite \
    curl \
    wget \
    iputils-ping \
    net-tools \
    etherwake \
    ssh-client \
    mosquitto-clients \
    mono-xsp4 \
    mono-vbnc \
    avahi-discover \
    libavahi-compat-libdnssd-dev \
    libnss-mdns \
    avahi-daemon \
    avahi-utils \
    mdns-scan \
    ffmpeg \
    aha \
    flite \
    alsa-utils && \
    rm -rf /var/lib/apt/lists/*

RUN apt autoremove && \
  apt autoclean

RUN chsh -s /bin/bash
ENV SHELL=/bin/bash

RUN echo "**** install s6-overlay ****" && \
  if [ -z ${S6_RELEASE+x} ]; then \
    S6_RELEASE=$(curl -sX GET "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  S6_URL=$(curl -sX GET "https://api.github.com/repos/just-containers/s6-overlay/releases/tags/${S6_RELEASE}" \
  | jq -r '.assets[] | select(.browser_download_url | endswith("amd64.tar.gz")) | .browser_download_url') && \
  curl -o \
    /tmp/s6.tar.gz -L \
    "${S6_URL}" && \
  tar xf /tmp/s6.tar.gz -C / && \ 
  echo "**** clean up ****" && \
  touch /DO_INSTALL && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY overlay /

ARG AVAHI
RUN [ "${AVAHI:-1}" = "1" ] || (echo "Removing Avahi" && rm -rf /etc/services.d/avahi /etc/services.d/dbus)

VOLUME [ "$HS_HOME" ] 
EXPOSE 80 8888 10200 10300 10401 11000

ENTRYPOINT [ "/init" ]
