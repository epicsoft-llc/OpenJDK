FROM debian:13.6-slim

ENV DEBIAN_VERSION="13.6"
ENV JAVA_VERSION="25.0.4"

ARG BUILD_DATE="development"
LABEL org.label-schema.name="OpenJDK-JRE" \
      org.label-schema.description="OpenJDK runtime based on Debian Linux" \
      org.label-schema.vendor="epicsoft LLC / Alexander Schwarz <info@epicsoft.one>" \
      org.label-schema.version="$JAVA_VERSION" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.url="https://gitlab.com/epicsoft-networks/openjdk" \
      org.label-schema.vcs-url="https://gitlab.com/epicsoft-networks/openjdk/tree/main"

LABEL image.name="epicsoft_openjdk_jre" \
      image.description="OpenJDK runtime based on Debian Linux" \
      maintainer="epicsoft LLC" \
      maintainer.name="Alexander Schwarz <info@epicsoft.one>" \
      maintainer.copyright="Copyright 2023-2026 epicsoft LLC / Alexander Schwarz" \
      license="MIT" \
      debian_version="$DEBIAN_VERSION" \
      java_version="$JAVA_VERSION"

RUN apt-get update \
 && apt-get install --no-install-recommends -y openjdk-25-jre-headless=25.0.4.1+1-1~deb13u1 \
                                               ca-certificates \
                                               fontconfig \
                                               fonts-dejavu \
                                               fonts-liberation \
                                               fonts-liberation-sans-narrow \
                                               libasound2t64 \
                                               libfreetype6 \
                                               libharfbuzz0b \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists/*
