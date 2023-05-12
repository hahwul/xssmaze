# BUILDER
FROM crystallang/crystal:latest-alpine As builder

WORKDIR /xssmaze
COPY . .

RUN shards install
RUN shards build --release --no-debug

# RUNNING
#FROM scratch
#WORKDIR /app/
#COPY --from=builder /xssmaze/bin/xssmaze /app/xssmaze

CMD ["/xssmaze/bin/xssmaze"]