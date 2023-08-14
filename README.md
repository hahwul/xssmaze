<img src="https://user-images.githubusercontent.com/13212227/228863802-7a020ae4-fe15-48ad-a10a-5e81ac7f9324.png" style="width:200px;">

[![Crystal CI](https://github.com/hahwul/xssmaze/actions/workflows/crystal.yml/badge.svg)](https://github.com/hahwul/xssmaze/actions/workflows/crystal.yml)
[![Docker](https://github.com/hahwul/xssmaze/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/hahwul/xssmaze/actions/workflows/docker-publish.yml)

XSSMaze is a web service configured to be vulnerable to XSS and is intended to measure and enhance the performance of security testing tools. You can find several vulnerable cases in the list below.

## Build
```bash
# Install dependencies
shards install

# Build
shards build # Dev build
shards build --release --no-debug --production

# Run XSSMaze
# Defatul: http://0.0.0.0:3000
./bin/xssmaze
```

## Installation
### With Docker
```bash
docker pull ghcr.io/hahwul/xssmaze:main
```

## Map API
```
curl http://localhost:3000/map/txt
curl http://localhost:3000/map/json
```

```http
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 611
Content-Type: application/json
X-Powered-By: Kemal

{
    "endpoints": [
        "/basic/level1/?query=a",
        "/basic/level2/?query=a",
        "/basic/level3/?query=a",
        "/basic/level4/?query=a",
        "/basic/level5/?query=a",
        "/basic/level6/?query=a",
        "/basic/level7/?query=a",
        "/dom/level1/",
        "/dom/level2/",
        "/dom/level3/",
        "/dom/level4/"
        ...
    ]
}
```
