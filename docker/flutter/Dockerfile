FROM debian:bookworm-slim

ARG FLUTTER_VERSION=3.47.1

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git unzip xz-utils zip \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m dev
USER dev

ENV FLUTTER_HOME=/home/dev/flutter
ENV PATH="${FLUTTER_HOME}/bin:/home/dev/.pub-cache/bin:${PATH}"

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} \
      https://github.com/flutter/flutter.git ${FLUTTER_HOME} \
    && mkdir -p /home/dev/.pub-cache \
    && flutter config --no-analytics --enable-web --no-enable-linux-desktop \
    && flutter precache --web \
    && flutter --version

WORKDIR /workspace