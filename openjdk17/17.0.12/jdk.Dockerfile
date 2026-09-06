FROM docker:27.0.3-dind

ENV DOCKER_VERSION="27.0.3"
ENV ALPINE_VERSION="3.20.1"
ENV JAVA_VERSION="17.0.12"

ARG BUILD_DATE="development"
LABEL org.label-schema.name="OpenJDK-JDK" \
      org.label-schema.description="OpenJDK-JDK based on Docker in Docker (DinD) and Alpine Linux" \
      org.label-schema.vendor="epicsoft LLC / Alexander Schwarz <info@epicsoft.one>" \
      org.label-schema.version="$JAVA_VERSION" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.url="https://gitlab.com/epicsoft-networks/openjdk" \
      org.label-schema.vcs-url="https://gitlab.com/epicsoft-networks/openjdk/tree/main"

LABEL image.name="epicsoft_openjdk_jdk" \
      image.description="OpenJDK-JDK based on Docker in Docker (DinD) and Alpine Linux" \
      maintainer="epicsoft LLC" \
      maintainer.name="Alexander Schwarz <info@epicsoft.one>" \
      maintainer.copyright="Copyright 2024 epicsoft LLC / Alexander Schwarz" \
      license="MIT" \
      docker_version="$DOCKER_VERSION" \
      alpine_version="$ALPINE_VERSION" \
      java_version="$JAVA_VERSION"

RUN apk --no-cache add openjdk17-jdk=17.0.12_p7-r0 \
                       ca-certificates \
                       jq \
                       ttf-dejavu \
 && update-ca-certificates \
 && rm -rf /var/cache/apk/*
