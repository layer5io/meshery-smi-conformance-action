FROM alpine:latest

COPY entrypoint.sh /entrypoint.sh

RUN apk add --no-cache \
  bash \
  ca-certificates \
  curl \
  jq


ENTRYPOINT ["/entrypoint.sh"]
