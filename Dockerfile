FROM node:lts-alpine as cdn_base
WORKDIR /srv
RUN npm install -g fx
COPY cdn-npm.ash /usr/local/bin/cdn-npm.ash

FROM cdn_base as cdn_src
COPY cdn-deps.txt ./
RUN cdn-npm.ash ./cdn-deps.txt
RUN cdn-npm.ash ./cdn-deps.txt

FROM caddy:2-alpine
CMD ["/usr/bin/caddy", "file-server", "-root", "/srv", "-browse"]
COPY --from=cdn_src /srv/cdn/ /srv/cdn/

