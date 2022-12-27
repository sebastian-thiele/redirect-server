# redirect-server

redirect-server is a URL shortener and redirection service.

## Quick start

### Docker

First you have to build the Docker image:

```shell
docker build --pull --rm -t redirect-server .
```

Once the build has been successfully completed, run the Docker image:

```shell
docker run \
    -d \
    -p 8080:8080 \
    --rm \
    --name redirect-server \
    redirect-server
```

### Maven

Build an executable jar-file:

```shell
mvn clean package
```

Once the jar-file was built successfully, run it with:

```shell
java -jar target/redirect-server-<version>.jar, e.g. java -jar target/redirect-server-0.0.1-SNAPSHOT.jar
```

## API
