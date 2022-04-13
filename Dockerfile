FROM alpine:latest

RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main git

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
