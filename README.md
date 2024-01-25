# OpenJDK

Java OpenJDK-JDK and -JRE

## OpenJDK-JDK

OpenJDK-JDK based on Docker in Docker (DinD) and Alpine Linux.

This image is intended for building and can be used in a pipeline.

## OpenJDK-JRE

OpenJDK-JRE based on Alpine Linux.

This image is for the runtime environment.

## Examples

### Build pipeline

Build a Java Gradle project in a pipeline

```yml
exampleProjectBuild:
  stage: build
  image: registry.gitlab.com/epicsoft-networks/openjdk:jdk-latest
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
    - docker build -t $DOCKER_IMAGE . --build-arg JAR_FILE=$JAVA_JAR_PATH/exampleProject-${VERSION}.jar --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
    - docker push $DOCKER_IMAGE
```

### Dockerfile

```dockerfile
FROM registry.gitlab.com/epicsoft-networks/openjdk:jre-latest

ARG BUILD_DATE="development"
LABEL org.label-schema.name="exampleProject" \
      org.label-schema.description="Example project" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.build-date="$BUILD_DATE" \

ENV JAVA_SERVER="-server" \
    JAVA_DOCKER="-XX:+UseContainerSupport -XX:MaxRAMPercentage=90" \
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

#  License

MIT License see [LICENSE](LICENSE)

Please note that the MIT license only applies to the files created by epicsoft LLC.
Other software may be licensed under other licenses.
