FROM ubuntu:18.04
MAINTAINER @BenjaminHae https://github.com/BenjaminHae

ENV MPD_VERSION 0.19.12-r0
ENV MPC_VERSION 0.27-r0

# https://docs.docker.com/engine/reference/builder/#arg
ARG user=mpd
ARG group=audio

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -q --yes pulseaudio-utils \
    mpd mpc
    
RUN mkdir -p /var/lib/mpd/music \
    && mkdir -p /var/lib/mpd/playlists \
    && mkdir -p /var/lib/mpd/database \
    && mkdir -p /var/log/mpd/mpd.log \
    && chown -R ${user}:${group} /var/lib/mpd \
    && chown -R ${user}:${group} /var/log/mpd/mpd.log

# Declare a music , playlists and database volume (state, tag_cache and sticker.sql)
VOLUME ["/var/lib/mpd/music", "/var/lib/mpd/playlists", "/var/lib/mpd/database"]
COPY mpd.conf /etc/mpd.conf
COPY pulse-client.conf /etc/pulse/client.conf

# Entry point for mpc update and stuff
EXPOSE 6600

USER ${user}

CMD ["mpd", "--stdout", "--no-daemon"]
