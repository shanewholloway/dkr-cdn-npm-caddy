FROM caddy:2-alpine as cdn_npm_caddy
COPY Caddyfile /etc/caddy/Caddyfile

FROM node:lts-alpine as cdn_npm_builder
WORKDIR /srv
COPY cdn-npm.ash /usr/local/bin/cdn-npm
RUN npm install -g fx ; echo "ky@0.28.7" > cdn-deps.txt
CMD ["/bin/ash", "/usr/local/bin/cdn-npm", "./cdn-deps.txt"]

FROM cdn_npm_builder as cdn_npm_example
COPY ./cdn-npm/cdn-deps.txt ./
RUN cdn-npm ./cdn-deps.txt
RUN cdn-npm ./cdn-deps.txt

FROM cdn_npm_caddy
COPY --from=cdn_npm_example /srv/cdn/ /srv/cdn/

