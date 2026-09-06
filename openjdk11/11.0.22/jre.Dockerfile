FROM alpine:3.19.1

ENV ALPINE_VERSION="3.19.1"
ENV JAVA_VERSION="11.0.22"

ARG BUILD_DATE="development"
LABEL org.label-schema.name="OpenJDK-JRE" \
      org.label-schema.description="OpenJDK runtime based on Alpine Linux" \
      org.label-schema.vendor="epicsoft LLC / Alexander Schwarz <info@epicsoft.one>" \
      org.label-schema.version="$JAVA_VERSION" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.url="https://gitlab.com/epicsoft-networks/openjdk" \
      org.label-schema.vcs-url="https://gitlab.com/epicsoft-networks/openjdk/tree/main"

LABEL image.name="epicsoft_openjdk_jre" \
      image.description="OpenJDK runtime based on Alpine Linux" \
      maintainer="epicsoft LLC" \
      maintainer.name="Alexander Schwarz <info@epicsoft.one>" \
      maintainer.copyright="Copyright 2024 epicsoft LLC / Alexander Schwarz" \
      license="MIT" \
      alpine_version="$ALPINE_VERSION" \
      java_version="$JAVA_VERSION"

RUN apk --no-cache add openjdk11-jre=11.0.22_p7-r0 \
                       ca-certificates \
                       ttf-dejavu \
 && update-ca-certificates \
 && rm -rf /var/cache/apk/*
