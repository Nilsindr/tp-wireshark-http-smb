FROM nginx:alpine

# Certificat auto-signe genere AU BUILD : aucune etape manuelle, 100%
# reproductible. Le warning navigateur "certificat non fiable" est
# VOULU : c'est un bon pretexte pour parler des autorites de certification.
RUN apk add --no-cache openssl && \
    mkdir -p /etc/nginx/certs && \
    openssl req -x509 -nodes -newkey rsa:2048 -days 825 \
      -keyout /etc/nginx/certs/server.key \
      -out   /etc/nginx/certs/server.crt \
      -subj "/C=CH/ST=Vaud/L=Lausanne/O=Labo Ecole EPFL/CN=labo.local"

COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443
