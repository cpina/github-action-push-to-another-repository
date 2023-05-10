FROM alpine:latest

RUN apk add --no-cache git git-lfs openssh-client

COPY entrypoint.sh /entrypoint.sh
COPY functions.sh /functions.sh

ENTRYPOINT ["/entrypoint.sh"]
