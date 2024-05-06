# BUILDER
FROM crystallang/crystal:latest-alpine As builder

WORKDIR /xssmaze
COPY . .

RUN shards install
RUN shards build --release --no-debug --production

# RUNNER
FROM alpine
USER 2:2

COPY --from=builder /xssmaze/bin/xssmaze /app/xssmaze
COPY --from=builder /etc/ssl/cert.pem /etc/ssl/

WORKDIR /app/

CMD ["/xssmaze/bin/xssmaze"]
