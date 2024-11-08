#!/usr/bin/sh

git pull

echo "$(date --utc ): Releasing new server version"
echo "Running build"

docker compose build

OLD_CONTAINER=$(docker ps -aqf "name=next-docker")
docker container rm -f $OLD_CONTAINER
docker compose up next-docker -d
echo "Reloading caddy"
CADDY_CONTAINER=$(docker ps -aqf "name=caddy")
docker exec $CADDY_CONTAINER caddy reload -c /etc/caddy/Caddyfile

