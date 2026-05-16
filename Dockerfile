##= BUILDER =##
FROM crystallang/crystal:1.20.1 AS builder
WORKDIR /xssmaze

RUN apt-get update && \
    apt-get install -y --no-install-recommends zlib1g-dev pkg-config && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY shard.yml shard.lock ./
RUN shards install --production

COPY . .
RUN shards build --release --no-debug --production && \
    strip /xssmaze/bin/xssmaze

##= RUNNER =##
FROM debian:13-slim

LABEL org.opencontainers.image.title="XSSMaze"
LABEL org.opencontainers.image.description="Intentionally vulnerable XSS lab used to benchmark security testing tools."
LABEL org.opencontainers.image.authors="HAHWUL <hahwul@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/hahwul/xssmaze"
LABEL org.opencontainers.image.documentation="https://github.com/hahwul/xssmaze"
LABEL org.opencontainers.image.licenses="MIT"

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends libgc1 libpcre2-8-0 libssl3 zlib1g ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /xssmaze/bin/xssmaze /usr/local/bin/xssmaze

# Run as a non-root user. Loopback default is overridden here because the
# container is the network boundary — bind to 0.0.0.0 so port mapping works.
USER 2:2
EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/xssmaze"]
CMD ["-b", "0.0.0.0"]
