FROM ubuntu:noble

RUN echo "bust the cache 20260405.2"

ENV DEBIAN_FRONTEND=noninteractive \
    DEBUILD_LINTIAN=no \
    DISTRO=ubuntu-24.04-noble \
    IS_NIGHTLY=1 \
    CLANG_VERSION=20 \
    OUT=/mnt/project/hhvm/gold \
    HHVM_DISABLE_NUMA=true \
    HHVM_DISABLE_PERSONALITY=true

RUN apt update -y && apt install -y \
    devscripts \
    equivs \
    git \
    wget \
    lsb-release \
    software-properties-common \
    gpg \
    clang \
    clang-20 \
    libc++-20-dev \
    libc++abi-20-dev \
    ca-certificates \
    sudo

RUN if [ -f /etc/alternatives/cc ]; then update-alternatives --remove-all cc; fi && \
    if [ -f /etc/alternatives/c++ ]; then update-alternatives --remove-all c++; fi && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang++-20 500 && \
    update-alternatives --set cc /usr/bin/clang++-20 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-20 500 && \
    update-alternatives --set c++ /usr/bin/clang++-20

WORKDIR /mnt/project

ARG TAG_NAME="hhvm-next"
ARG HHVM_VERSION_MAJOR=6
ARG HHVM_VERSION_MINOR=80
ARG HHVM_VERSION_PATCH=0
ARG HHVM_BRANCH_NAME=master
ENV VERSION="$HHVM_VERSION_MAJOR.$HHVM_VERSION_MINOR.$HHVM_VERSION_PATCH"

RUN echo "Clone cache buster 20260405.4"

RUN git clone --recurse-submodules -b $HHVM_BRANCH_NAME --single-branch https://github.com/hershel-theodore-layton/hhvm hhvm

WORKDIR /mnt/project/hhvm

RUN sed "s/MAJOR 6/MAJOR $HHVM_VERSION_MAJOR/" -i hphp/runtime/version.h && \
    sed "s/MINOR 79/MINOR $HHVM_VERSION_MINOR/" -i hphp/runtime/version.h && \
    sed "s/PATCH 0/PATCH $HHVM_VERSION_PATCH/" -i hphp/runtime/version.h && \
    sed "s/-dev//" -i hphp/runtime/version.h

# If you get a build error, try compiling with fewer threads. This makes reading
# the error messages a lot easier. By default, the build uses all the threads.
# RUN sed 's#parallel=\$(grep -E -c '\''\^processor'\'' /proc/cpuinfo)#parallel=1#' -i ci/bin/make-debianish-package

RUN ci/bin/make-debianish-package