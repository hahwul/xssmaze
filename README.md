# XSSMaze

[![Crystal CI](https://github.com/hahwul/xssmaze/actions/workflows/crystal.yml/badge.svg)](https://github.com/hahwul/xssmaze/actions/workflows/crystal.yml)

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