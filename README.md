# OpenJDK

This Docker image is managed and kept up to date by [epicsoft LLC](https://epicsoft.one).

Java OpenJDK-JDK and -JRE Docker images based on official images.

* Base image for OpenJDK-JDK: https://hub.docker.com/_/docker
* Base image for OpenJDK-JRE: https://hub.docker.com/_/alpine
* Base image for the Debian variants: https://hub.docker.com/_/debian
* Dockerfiles: https://gitlab.com/epicsoft-networks/openjdk/tree/main
* Repository: https://gitlab.com/epicsoft-networks/openjdk/tree/main
* Container-Registry: https://gitlab.com/epicsoft-networks/openjdk/container_registry
* Docker Hub: https://hub.docker.com/r/epicsoft/openjdk

## OpenJDK-JDK

OpenJDK-JDK based on official image Docker in Docker (DinD) and indirectly on Alpine Linux.  
This image is intended for building and can be used in a pipeline.

## OpenJDK-JRE

OpenJDK-JRE based on official images Alpine Linux.  
This image is for the runtime environment.

## OpenJDK Debian headless

OpenJDK-JDK and -JRE based on the official Debian slim image with the headless Java packages.  
These images are for a glibc runtime environment, e.g. for native libraries that do not run on musl.  
Headless means AWT is available for font rendering, image and PDF generation, but not for GUI windows.  
The Debian JDK image is not based on Docker in Docker and contains no Docker CLI.

## Platforms

All images are published as multi-platform manifests for `linux/amd64` and `linux/arm64`.  
Docker automatically pulls the matching architecture.

## Versions

`jdk` `jdk25` `jdk25.0.4` `jdk25-latest` `jdk-latest`  
based on Docker DinD indirectly on Alpine with Java JDK 25 - build `weekly`

`jre` `jre25` `jre25.0.4` `jre25-latest` `jre-latest` `latest`  
based on Alpine image with Java JRE 25 - build `weekly`

`jdk-debian-headless` `jdk25-debian-headless` `jdk25.0.4-debian-headless` `jdk25-debian-headless-latest` `jdk-debian-headless-latest`  
based on Debian slim image with Java JDK 25 headless - build `weekly`

`jre-debian-headless` `jre25-debian-headless` `jre25.0.4-debian-headless` `jre25-debian-headless-latest` `jre-debian-headless-latest`  
based on Debian slim image with Java JRE 25 headless - build `weekly`

`jdk21` `jdk21.0.12` `jdk21-latest`  
based on Docker DinD indirectly on Alpine with Java JDK 21 - build `weekly`

`jre21` `jre21.0.12` `jre21-latest`  
based on Alpine image with Java JRE 21 - build `weekly`

`jdk17` `jdk17.0.20` `jdk17-latest`  
based on Docker DinD indirectly on Alpine with Java JDK 17 - build `weekly`

`jre17` `jre17.0.20` `jre17-latest`  
based on Alpine image with Java JRE 17 - build `weekly`

`jdk11` `jdk11.0.32` `jdk11-latest`  
based on Docker DinD indirectly on Alpine with Java JDK 11 - build `weekly`

`jre11` `jre11.0.32` `jre11-latest`  
based on Alpine image with Java JRE 11 - build `weekly`

For older versions see subdirectories
  - OpenJDK 25 JDK & JRE - https://gitlab.com/epicsoft-networks/openjdk/tree/main/openjdk25
  - OpenJDK 21 JDK & JRE - https://gitlab.com/epicsoft-networks/openjdk/tree/main/openjdk21
  - OpenJDK 17 JDK & JRE - https://gitlab.com/epicsoft-networks/openjdk/tree/main/openjdk17
  - OpenJDK 11 JDK & JRE - https://gitlab.com/epicsoft-networks/openjdk/tree/main/openjdk11

## Additional Alpine packages

Alpine packages are installed in the current image in the latest version - https://pkgs.alpinelinux.org/packages
  - ca-certificates _(JDK & JRE)_
  - ttf-dejavu _(JDK & JRE)_
  - ttf-liberation _(JDK & JRE)_
  - jq _(only JDK)_

## Additional Debian packages

Debian packages are installed in the current image in the latest version - https://packages.debian.org
  - ca-certificates _(JDK & JRE)_
  - fontconfig _(JDK & JRE)_
  - fonts-dejavu _(JDK & JRE)_
  - fonts-liberation _(JDK & JRE)_
  - fonts-liberation-sans-narrow _(JDK & JRE)_
  - libasound2t64 _(JDK & JRE)_
  - libfreetype6 _(JDK & JRE)_
  - libharfbuzz0b _(JDK & JRE)_
  - jq _(only JDK)_

## Examples

### Example usage for GitLab CI/CD

Build a Java Gradle project in GitLab CI/CD pipeline

`.gitlab-ci.yml`

```yml
stages:
  - build

variables:
  VERSION: "1.0.0" 

exampleProjectBuild:
  stage: build
  image: epicsoft/openjdk:jdk-latest
  services:
    - docker:dind
  variables:
    DOCKER_IMAGE: $CI_REGISTRY:$VERSION
    JAVA_JAR_PATH: build/libs
  before_script:
    - docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY
  after_script:
    - docker logout $CI_REGISTRY
  script:
    - ./gradlew build --warning-mode all
    - docker build -t $DOCKER_IMAGE . --build-arg JAR_FILE=$JAVA_JAR_PATH/exampleProject-${VERSION}.jar --build-arg VERSION=$VERSION --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
    - docker push $DOCKER_IMAGE
```

### Example usage for Dockerfile

```dockerfile
FROM epicsoft/openjdk:jre-latest

ARG VERSION="development"
ARG BUILD_DATE="development"
LABEL org.label-schema.name="exampleProject" \
      org.label-schema.description="Example project" \
      org.label-schema.version="$VERSION" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.build-date="$BUILD_DATE"

ENV JAVA_SERVER="-server" \
    JAVA_DOCKER="-XX:+UseContainerSupport -XX:MaxRAMPercentage=80" \
    JAVA_SECURITY="-Djava.security.egd=file:/dev/./urandom" \
    JAVA_ENCODING="-Dfile.encoding=UTF-8" \
    JAVA_TIMEZONE="-Duser.timezone=GMT" \
    JAVA_ERROR="-XX:+ExitOnOutOfMemoryError" \
    JAVA_OPTS=""

ARG JAR_FILE
COPY $JAR_FILE /app.jar

EXPOSE 8080

ENTRYPOINT [ "sh", "-c", "java $JAVA_SERVER $JAVA_DOCKER $JAVA_SECURITY $JAVA_ENCODING $JAVA_TIMEZONE $JAVA_ERROR $JAVA_OPTS -jar /app.jar" ]
```

## End of life

Upstream support for these Java versions ends, the images are no longer updated afterwards - https://adoptium.net/support
  - Java 11 _(October 2027)_
  - Java 17 _(October 2027)_
  - Java 21 _(December 2029)_
  - Java 25 _(September 2031)_

## License

MIT License see [LICENSE](https://gitlab.com/epicsoft-networks/openjdk/blob/main/LICENSE)

Please note that the MIT license only applies to the files created by epicsoft LLC. Other software may be licensed under other licenses.
