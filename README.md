# OpenJDK

This Docker image is managed and kept up to date by [epicsoft LLC](https://epicsoft.one).

Java OpenJDK-JDK and -JRE Docker images based on official images.

* Base image for OpenJDK-JDK: https://hub.docker.com/_/docker
* Base image for OpenJDK-JRE: https://hub.docker.com/_/alpine
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

## Versions

`jdk` `jdk21` `jdk21.0.9` `jdk21-latest` `jdk-latest`  
based on `docker:29.0.1-dind` indirectly on Alpine `3.22.2` with Java JDK `21.0.9` - build `weekly`
  - Alpine package `openjdk21-jdk` version `21.0.9_p10-r0` - https://pkgs.alpinelinux.org/packages?name=openjdk21-jdk&branch=v3.21

`jre` `jre21` `jre21.0.9` `jre21-latest` `jre-latest` `latest`  
based on `alpine:3.22.2` image with Java JRE `21.0.9` - build `weekly`
  - Alpine package `openjdk21-jre` version `21.0.9_p10-r0` - https://pkgs.alpinelinux.org/packages?name=openjdk21-jre&branch=v3.21

`jdk17` `jdk17.0.17` `jdk17-latest`  
based on `docker:29.0.1-dind` indirectly on Alpine `3.22.2` with Java JDK `17.0.17` - build `weekly`
  - Alpine package `openjdk17-jdk` version `17.0.17_p10-r0` - https://pkgs.alpinelinux.org/packages?name=openjdk17-jdk&branch=v3.21

`jre17` `jre17.0.17` `jre17-latest`  
based on `alpine:3.22.2` image with Java JRE `17.0.17` - build `weekly`
  - Alpine package `openjdk17-jre` version `17.0.17_p10-r0` - https://pkgs.alpinelinux.org/packages?name=openjdk17-jre&branch=v3.21

`jdk11` `jdk11.0.29` `jdk11-latest`  
based on `docker:29.0.1-dind` indirectly on Alpine `3.22.2` with Java JDK `11.0.29` - build `weekly`
  - Alpine package `openjdk11-jdk` version `11.0.29_p7-r0` - https://pkgs.alpinelinux.org/packages?name=openjdk11-jdk&branch=v3.21

`jre11` `jre11.0.29` `jre11-latest`  
based on `alpine:3.22.2` image with Java JRE `11.0.29` - build `weekly`
  - Alpine package `openjdk11-jre` version `11.0.29_p7-r0` - https://pkgs.alpinelinux.org/packages?name=openjdk11-jre&branch=v3.21

For older versions see subdirectories
  - OpenJDK 11 JDK & JRE - https://gitlab.com/epicsoft-networks/openjdk/tree/main/openjdk11
  - OpenJDK 17 JDK & JRE - https://gitlab.com/epicsoft-networks/openjdk/tree/main/openjdk17
  - OpenJDK 21 JDK & JRE - https://gitlab.com/epicsoft-networks/openjdk/tree/main/openjdk21

## Additional Alpine packages

Alpine packages are installed in the current image in the latest version - https://pkgs.alpinelinux.org/packages
  - ca-certificates _(JDK & JRE)_
  - ttf-dejavu _(JDK & JRE)_
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

## License

MIT License see [LICENSE](https://gitlab.com/epicsoft-networks/openjdk/blob/main/LICENSE)

Please note that the MIT license only applies to the files created by epicsoft LLC. Other software may be licensed under other licenses.
