<img src="https://user-images.githubusercontent.com/13212227/228863802-7a020ae4-fe15-48ad-a10a-5e81ac7f9324.png" style="width:200px;">

[![Crystal CI](https://github.com/hahwul/xssmaze/actions/workflows/crystal.yml/badge.svg)](https://github.com/hahwul/xssmaze/actions/workflows/crystal.yml)
[![Docker](https://github.com/hahwul/xssmaze/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/hahwul/xssmaze/actions/workflows/docker-publish.yml)

XSSMaze is a web service configured to be vulnerable to XSS and is intended to measure and enhance the performance of security testing tools. You can find several vulnerable cases in the list below.

## Build
```bash
shards install
shards build

./bin/xssmaze
# Default: http://0.0.0.0:3000
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
