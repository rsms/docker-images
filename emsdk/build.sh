#!/bin/sh
set -e

IMAGE_NAME=rsms/emsdk
BUILD_IMAGE_NAME=$IMAGE_NAME:__build
BUILD_INSTANCE_NAME=rsms_emsdk__build

# fetch version
EMSCRIPTEN_VERSION=$( \
  git ls-remote --tags https://github.com/kripken/emscripten.git \
  | grep 'refs/tags/1\.' \
  | sed -E 's/^.+refs\/tags\///' \
  | sort --version-sort \
  | tail -n 1 )
echo "EMSCRIPTEN_VERSION=$EMSCRIPTEN_VERSION"

# update version in Dockerfile
sed -E \
  "s/ENV EMSCRIPTEN_VERSION .+/ENV EMSCRIPTEN_VERSION $EMSCRIPTEN_VERSION/g" \
  Dockerfile > Dockerfile2
mv -f Dockerfile2 Dockerfile

# make sure a container with this image is not currently running
BUILD_CONTAINER_ID=$(docker ps -aqf name=$BUILD_INSTANCE_NAME)
if [[ "$BUILD_CONTAINER_ID" != "" ]]; then
  echo "killing $BUILD_INSTANCE_NAME with instance id $BUILD_CONTAINER_ID"
  docker kill $BUILD_CONTAINER_ID
fi

# build the image
echo "Building image. This might take a while..."
docker build -f Dockerfile -t $BUILD_IMAGE_NAME --squash .
# docker build -f Dockerfile -t $BUILD_IMAGE_NAME .

# read values of /root/env which we will later transfer to ENV of new container
EMSCRIPTEN_VERSION=
commit_args=()
for line in $(docker run --rm --name $BUILD_INSTANCE_NAME $BUILD_IMAGE_NAME /bin/cat /root/env); do
  if [[ "$line" == "EMSCRIPTEN_VERSION="* ]]; then
    # evaluate line, setting EMSCRIPTEN_VERSION in our local env
    eval $line
  fi
  commit_args+=( --change "ENV $line" )
done

# launch detached container
docker run --rm --name $BUILD_INSTANCE_NAME -dit $BUILD_IMAGE_NAME /bin/bash

# commit changes to image, making :latest
BUILD_CONTAINER_ID=$(docker ps -aqf name=$BUILD_INSTANCE_NAME)
docker commit "${commit_args[@]}" $BUILD_CONTAINER_ID ${IMAGE_NAME}:latest

# kill & remove temporary container
docker kill $BUILD_CONTAINER_ID
docker rmi $BUILD_IMAGE_NAME

# tag version
if [ "$EMSCRIPTEN_VERSION" = "" ]; then
  echo "failed to find EMSCRIPTEN_VERSION in image's /root/env -- skipping version tagging" >&2
else
  echo "EMSCRIPTEN_VERSION: $EMSCRIPTEN_VERSION"
  docker tag $IMAGE_NAME:latest $IMAGE_NAME:$EMSCRIPTEN_VERSION
fi

echo "Testing the image: building test case"
cd example
docker run --rm -v "$PWD:/src" rsms/emsdk:latest emcc hello.c -s WASM=1 -o hello.js
if which node >/dev/null; then
  echo node hello.js
  node hello.js
fi

echo "You can push the image to Docker hub:"
echo "docker push rsms/emsdk:$EMSCRIPTEN_VERSION"
echo "docker push rsms/emsdk:latest"

# docker run --rm -it -v "$PWD:/src" rsms/emsdk:latest
