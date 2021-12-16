# Docker local CDN for NPM

Creates a local `cdn/` directory from NPM dependencies.


### CDN NPM Script

The [`ash cdn-npm.ash npm-depdendencies.txt`](./cdn-npm.ash) script one dependency per line from `npm-dependencies.txt`. The script resolve the dependency using `npm pack`, downloads the tarball, and extracts the tarball into `cdn/pkg-name@pkg-version/`. The resulting `cdn/` directory is suitable for use in a static file server.


### Caddy2 docker

The [`Dockerfile`](./Dockerfile) multi-stage build recipe uses `cdn-npm.ash` and 
`cdn-deps.txt` to build the CDN and then bundle the `cdn/` directory into a [Caddy2](https://caddyserver.com) static fileserver docker image.


## License

tl;dr -- Free to use.

[Creative Commons Public Domain (CC0)](https://creativecommons.org/publicdomain/zero/1.0/)
or [MIT License](./LICENSE) at your discretion. 

