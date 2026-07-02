FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends samba && \
    rm -rf /var/lib/apt/lists/*

COPY smb.conf /etc/samba/smb.conf
COPY entrypoint.sh /entrypoint.sh
# Retire d'eventuels retours chariot Windows (CRLF) : sinon le script
# clone sur Windows plante avec le code 255 (#!/bin/sh\r introuvable).
RUN sed -i 's/\r$//' /entrypoint.sh /etc/samba/smb.conf && chmod +x /entrypoint.sh

EXPOSE 445
ENTRYPOINT ["/entrypoint.sh"]
