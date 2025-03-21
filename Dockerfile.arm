# BUILDER
FROM 84codes/crystal:latest AS builder

WORKDIR /xssmaze
COPY . .

RUN shards install
RUN shards build --release --no-debug --production

# RUNNER
FROM arm64v8/alpine:latest

RUN apk add --no-cache libgcc pcre2 libstdc++ libc6-compat

COPY --from=builder /xssmaze/bin/xssmaze /app/xssmaze
COPY --from=builder /etc/ssl/cert.pem /etc/ssl/

WORKDIR /app/

CMD ["/app/xssmaze"]