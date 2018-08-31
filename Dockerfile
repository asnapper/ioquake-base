FROM debian:stable-slim AS build
LABEL maintainer="Matthias Löffel <matthias.loeffel@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y
RUN apt-get install -y git gcc make libsdl2-dev musl musl-dev musl-tools

RUN git clone git://github.com/ioquake/ioq3.git /ioq3
WORKDIR /ioq3
RUN CFLAGS=-Wno-misleading-indentation\ -Wno-maybe-uninitialized \
    LDFLAGS=-static \
    CC=musl-gcc \
    BUILD_SERVER=1 \
    BUILD_CLIENT=0 \
    BUILD_GAME_SO=0 \
    USE_CURL=1 \
    USE_VOIP=1 \
    USE_CODEC_OPUS=1 \
    make -j8

FROM scratch

WORKDIR /ioq3
COPY --from=build /ioq3/build/release-linux-x86_64/ioq3ded.x86_64 /ioq3
COPY --from=build /ioq3/build/release-linux-x86_64/baseq3 /ioq3
COPY --from=build /ioq3/build/release-linux-x86_64/missionpack /ioq3

ENTRYPOINT ["./ioq3ded.x86_64"]
EXPOSE 27900-27999:27900-27999/udp