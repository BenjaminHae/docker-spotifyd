FROM ubuntu:18.04
MAINTAINER @BenjaminHae https://github.com/BenjaminHae

# https://docs.docker.com/engine/reference/builder/#arg
ARG user=spotify
ARG userid=47
ARG groupid=47
ARG BRANCH=master

RUN groupadd -g ${groupid} ${user} && useradd -u ${userid} -g ${groupid} -ms /bin/false ${user}
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -q --yes --no-install-recommends \
    pulseaudio-utils cargo libpulse-dev build-essential

RUN git clone --depth=1 --branch=${BRANCH} https://github.com/Spotifyd/spotifyd.git /tmp/spotifyd \
 && cd /tmp/spotifyd \
 && cargo build --release --features pulseaudio_backend

RUN apt-get remove  -q --yes --no-install-recommends \
    libpulse-dev cargo build-essential \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
    
COPY pulse-client.conf /etc/pulse/client.conf
RUN sed -i "s/USERID/${userid}/;" /etc/pulse/client.conf

USER ${user}
RUN mkdir -p /home/${user}/.config/

VOLUME ["/home/${user}/.config"]

CMD ["/usr/bin/spotifyd", "--no-daemon"]
