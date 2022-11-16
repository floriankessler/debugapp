# README

The resulting docker image offers

http://localhost/
http://localhost/stackadm/debug/ttyd
http://localhost/stackadm/debug/headers
http://localhost/stackadm/debug/headersJson
http://localhost/stackadm/debug/systeminfo

## Start app

```bash
docker run \
    --rm \
    --name debugapp \
    -p 80:80 \
    -ti \
    floriankessler/debugapp \
    ;
```

## Hack the app

```bash
# Run the app using local files
docker run \
    --rm \
    --name debugapp \
    -v "${PWD}"/rootfs/usr/local/openresty/nginx/conf/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf \
    -v "${PWD}"/rootfs/usr/local/openresty/nginx/conf/conf.d:/usr/local/openresty/nginx/conf/conf.d \
    -v "${PWD}"/rootfs/usr/local/openresty/nginx/lua:/usr/local/openresty/nginx/lua \
    -p 80:80 \
    -ti \
    floriankessler/debugapp \
    ;

# (Re-)start the app within the container
docker exec -ti debugapp sh

# Either
sv restart openresty

# or
while true; do
  sleep 2
  sv reload openresty
done
```

## Build and test a new app container

Set htpasswd, insert current git id, build and tag container image.

```bash
KE_DOCKERIMAGE=floriankessler/debugapp

change_htpasswd(){
  set -u
  htpasswd -bB rootfs/usr/local/openresty/nginx/conf/conf.d/default.htpasswd stackadm "stackadm"
  set +u
}

docker_build(){
set -u
KE_GIT_COMMIT_ID_BUILDER=$(git rev-parse --short HEAD)
change_htpasswd

# bake git id into image
cat << eof > rootfs/etc/app-release
# Build information
BUILD_TIME=$(date)
GIT_REPO=$(git remote -v show)
GIT_COMMIT_ID=${KE_GIT_COMMIT_ID_BUILDER}

# Application information
eof

docker build -t ${KE_DOCKERIMAGE}:latest -f Dockerfile . && \
docker tag ${KE_DOCKERIMAGE} ${KE_DOCKERIMAGE}:${KE_GIT_COMMIT_ID_BUILDER}
set +u
}

docker_build
```

## Push container

```bash
docker tag ${KE_DOCKERIMAGE}:${KE_GIT_COMMIT_ID_BUILDER} ${KE_DOCKERIMAGE}:latest
docker images ${KE_DOCKERIMAGE}

docker push --all-tags ${KE_DOCKERIMAGE}
```
