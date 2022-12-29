# redirect-server

redirect-server is a URL shortener and redirection service.

With the redirect-server you have the posiibility to use only one link for different targets (e.g. QR-Code).

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

## Redirect

The most common interaction is following a redirect. Therefore send a `GET` request to the redirect-server with the `key` in the path of the desired redirect.

```Text
GET <Scheme>://<URL>/<key>
```

**Example:**

```Text
GET http://localhost:8080/aTc1
```

To determine the target redirect, the HTTP header `User-Agent` (configurable `application.yml`) will be analyzed for a match with the stored reqex´s. If no reqex matches, the fallback redirect will be used.

Depending on how the redirect is configured, you will be either redirected permanently (HTTP Statuscode `301`) or temporarly (HTTP Statuscode `307`).

If the key does not exist, you will get a `404`.

## API

### Authentication

All requests to the API must be authenticated with an API-Token. This token has to be send with the HTTP header `Authorization`.

```text
Authorization: Bearer ldksjhfalkfaelfhaljfadslflasjf289u43dk4q98
```

### Error

Errors are indicated by HTTP status codes. The error response has the following JSON schema:

```json
{
  "type": "object",
  "properties": {
    "error": {
      "type": "object",
      "properties": {
        "code": { "type": "string" },
        "message": { "type": "string" },
        "details": {
          "type": "object",
          "properties": {
            "fields": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "name": { "type": "string" },
                  "message": {
                    "type": "array",
                    "items": { "type": "string" }
                  }
                },
                "required": [ "name", "message"]
              }
            }
          },
          "required": [ "fields" ]
        }
      },
      "required": [ "code", "message", "details" ],
      "additionalProperties": false
    }
  },
  "required": [ "error" ],
  "additionalProperties": false
}
```

**Example:**

```json
{
  "error": {
    "code": "INVALID_INPUT",
    "message": "Invalid input in field 'type': unknown enum",
    "details": {
      "fields": [
        {
          "name": "type",
          "message": ["unknown enum"]
        }
      ]
    }
  }
}
```

| Attribute | Description |
| --- | --- |
| code | Short string to indicating the type of the error (machine-parsable). |
| message | Textual description of the error (human-readable).  |
| details | Providing more details of the error (depends on the error-code). |

#### Error-Codes

| Code | Description |
| --- | --- |
| UNAUTHORIZED | Authentication missing or failed. |
| FORBIDDEN | Insufficient permissions for this request. |
| INVALID_INPUT | Error while parsing or processing the input. |
| JSON_ERROR | Invalid JSON input in the request. |
| NOT_FOUND | Entity not found. |
| SERVICE_ERROR | Error within the service. |

### Getting redirect

To get a redirect, send a `GET` request to `/api/redirect/<key>` and provide the key of the redirect in the path. If the redirect could not be found, you will get a `404`.

### Adding redirects

To add a new redirect, send a `POST` request to `/api/redirect` with the data of the desired redirect in the request body. The request body must match the following JSON schema:

```json
{
  "type": "object",
  "properties": {
    "key": { "type": "string" },
    "fallbackUrl": { "type": "string", "minLength": 1, "format": "uri" },
    "type": { "type": "string", "enum": [ "PERMANENT", "TEMPORARY" ]},
    "targets": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "regex": { "type": "string", "minLength": 1, "format": "regex" },
          "url": { "type": "string", "minLength": 1, "format": "uri" }
        },
        "required": [ "regex", "url" ]
      }
    }
  },
  "required": [ "fallbackUrl", "type" ],
  "additionalProperties": false
}
```

**Example:**

```json
{
  "key": "aTc1",
  "fallbackUrl": "https://somewhere.io",
  "type": "TEMPORARY",
  "targets": [
    {
      "regex": "/iPhone|iPad",
      "url": "https://app.store"
    },
    {
      "regex": "/[a|A]ndroid",
      "url": "https://play.store"
    }
  ]
}
```

You can use your own key for the redirect. If no key is specified, a key will be generated.

If the redirect was added successfully, the API will return with a `200`. If the redirect already exist, you will get a `406`.

### Editing redirects

To edit a redirect, send a `PUT` request to `/api/redirect/<key>` with the data of the desired redirect in the request body and provide the key of the redirect in the path. The request body must match the following JSON schema:

```json
{
  "type": "object",
  "properties": {
    "key": { "type": "string" },
    "fallbackUrl": { "type": "string", "minLength": 1, "format": "uri" },
    "type": { "type": "string", "enum": [ "PERMANENT", "TEMPORARY" ]},
    "targets": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "regex": { "type": "string", "minLength": 1, "format": "regex" },
          "url": { "type": "string", "minLength": 1, "format": "uri" }
        },
        "required": [ "regex", "url" ]
      }
    }
  },
  "required": [ "fallbackUrl", "type" ],
  "additionalProperties": false
}
```

**Example:**

```json
{
  "key": "aTc1",
  "fallbackUrl": "https://somewhere.cloud",
  "type": "TEMPORARY",
  "targets": [
    {
      "regex": "/iPhone|iPad",
      "url": "https://app.store"
    },
    {
      "regex": "/[a|A]ndroid",
      "url": "https://play.store"
    }
  ]
}
```

If the redirect was successfully updated, the API will return with a `200`. If the redirect could not be found, you will get a `404`. It is necessary, that the key in the path and in the request body match. Otherwise the API return with a `406`.

### Removing redirects

To remove a redirect, send a `DELETE` request to `/api/redirect/<key>` and provide the key of the redirect in the path.

If the redirect was successfully removed, the API will return with a `200`. If the redirect could not be found, you will get a `404`.
