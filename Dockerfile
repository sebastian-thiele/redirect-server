FROM maven:3-openjdk-17 as buildstage

WORKDIR /build

COPY ./pom.xml ./pom.xml
RUN mvn dependency:go-offline 

COPY ./src ./src
RUN mvn package

FROM eclipse-temurin:17-jre as workingstage

LABEL author="Sebastian Thiele"

RUN addgroup --system spring \
    && adduser --system --gid 101 spring

USER spring:spring

WORKDIR /home/app

COPY --from=buildstage --chown=spring:spring /build/target/redirect-server-*.jar ./app.jar

EXPOSE 8080

ENTRYPOINT [ "java", "-jar", "app.jar" ]