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
    pulseaudio-utils cargo libpulse-dev build-essential git ca-certificates libasound2-dev libssl-dev libdbus-1-dev

RUN git clone --depth=1 --branch=${BRANCH} https://github.com/Spotifyd/spotifyd.git /tmp/spotifyd \
 && cd /tmp/spotifyd \
 && cargo build --release --features pulseaudio_backend \
 && cp -r /tmp/spotifyd/target/release /home/${user}/spotifyd \
 && rm -r /tmp/spotifyd


RUN DEBIAN_FRONTEND=noninteractive apt-get remove -q --yes \
    libpulse-dev cargo build-essential git libssl-dev libdbus-1-dev \
 && DEBIAN_FRONTEND=noninteractive apt-get autoremove -q --yes \
 && DEBIAN_FRONTEND=noninteractive apt-get clean -q --yes \
 && rm -rf /var/lib/apt/lists/*
    
COPY pulse-client.conf /etc/pulse/client.conf
RUN sed -i "s/USERID/${userid}/;" /etc/pulse/client.conf

USER ${user}

VOLUME ["/home/${user}"]

CMD ["/home/spotify/spotifyd/spotifyd", "--no-daemon", "--config-path=/home/spotify/spotifyd.conf"]
