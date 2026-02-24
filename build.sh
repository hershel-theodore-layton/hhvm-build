#!/bin/sh
set -e

docker buildx inspect hhvm_unclipped_builder || docker buildx create \
  --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=-1 \
  --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=-1 \
  --name hhvm_unclipped_builder

if [ "$#" -ne 4 ]; then
    echo "Usage ./build.sh <hhvm-branch-name> <hhvm-major> <hhvm-minor> <hhvm-patch>"
    exit 1
fi

rm -f my.new.deb

docker buildx build --load -t $1-builder \
  --build-arg TAG_NAME=$1 \
  --build-arg HHVM_VERSION_MAJOR=$2 \
  --build-arg HHVM_VERSION_MINOR=$3 \
  --build-arg HHVM_VERSION_PATCH=$4 \
  --build-arg HHVM_BRANCH_NAME=$1 \
  --progress=plain . --builder hhvm_unclipped_builder
echo "Build complete, sleeping for a couple of seconds to make sure docker has the image ready..."
sleep 5

docker create --name $1-file-mule $1-builder:latest
docker cp $1-file-mule:/mnt/project/hhvm/gold/hhvm-nightly_$2.$3.$4-1~noble_amd64.deb my.new.deb
docker rm $1-file-mule

# echo "Deb file extracted, ready to build the publish container..."
sleep 5
docker build -t $1-full -f Dockerfile-publish --progress=plain .
docker build -t $1-basic -f Dockerfile-publish-basic --progress=plain .

echo "Script ran to completion..."
