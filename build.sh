#!/bin/sh
set -e
cd $(dirname $0)

#Usually set from the outside
: ${TARGET_ARCH:="$(uname -m)"}
: ${TARGET_IMG:=""}
: ${TAG:="latest"}
: ${BUILD:="true"}
: ${PUSH:="true"}
: ${MANIFEST:="false"}

#good defaults
: ${BASE:="alpine"}
: ${REPO:="angelnu/keepalived"}
: ${QEMU_VERSION:="v2.11.1"}


case $TARGET_ARCH in
armv7l|arm)
  ARCH_TAG="${TAG}-arm"
  ;;
aarch64)
  ARCH_TAG="${TAG}-aarch64"
  ;;
x86_64|amd64)
  ARCH_TAG="${TAG}-amd64"
  ;;
*)
  echo "Unknown arch $TARGET_ARCH"
  exit 1
  ;;
esac

###############################

if [ "$BUILD" = true ] ; then
  echo "BUILDING DOCKER $REPO:$ARCH_TAG"
  
  #Prepare qemu
  mkdir -p qemu
  cd qemu
  if [ ! -f qemu-"$TARGET_ARCH"-static ]; then
    echo "Running in arch $(uname -m) and with TARGET_ARCH $TARGET_ARCH"
    if [ "$TARGET_ARCH" = "amd64" -o "$TARGET_ARCH" = "$(uname -m)" ]; then
      touch qemu-"$TARGET_ARCH"-static
    else
      # Prepare qemu
      docker run --rm --privileged multiarch/qemu-user-static:register --reset
      curl -L -o qemu-"$TARGET_ARCH"-static.tar.gz https://github.com/multiarch/qemu-user-static/releases/download/"$QEMU_VERSION"/qemu-"$TARGET_ARCH"-static.tar.gz
      tar xzf qemu-"$TARGET_ARCH"-static.tar.gz
      rm qemu-"$TARGET_ARCH"-static.tar.gz
    fi
  fi
  cd ..

  #Build docker
  BASE=alpine
  if [ -n "$TARGET_IMG" ]; then
    BASE="$TARGET_IMG/$BASE"
  fi
  echo "Using base image: $BASE"
  docker build -t $REPO:$ARCH_TAG --build-arg BASE=$BASE --build-arg arch=$TARGET_ARCH .
fi

##############################

if [ "$PUSH" = true ] ; then
  echo "PUSHING TO DOCKER"
  docker push $REPO:$ARCH_TAG
fi

###############################

if [ "$MANIFEST" = true ] ; then
  echo "PUSHING MANIFEST for $ARCHS"
  
  for arch in $ARCHS; do
    echo
    echo "Add ${REPO}:${TAG}-${arch} to manifest ${REPO}:${TAG}"
    echo
    docker manifest create --amend ${REPO}:${TAG} ${REPO}/:${TAG}-${arch}
    docker manifest annotate       ${REPO}:${TAG} ${REPO}/:${TAG}-${arch} --arch ${arch}
  done

  echo
  echo "Push manifest ${REPO}:${TAG}"
  docker manifest push ${REPO}:${TAG}
fi
