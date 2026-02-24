FROM ubuntu:noble

RUN echo "bust the cache 1"

ENV DEBIAN_FRONTEND=noninteractive \
    DEBUILD_LINTIAN=no \
    DISTRO=ubuntu-24.04-noble \
    IS_NIGHTLY=1 \
    CLANG_VERSION=18 \
    OUT=/mnt/project/hhvm/gold \
    HHVM_DISABLE_NUMA=true \
    HHVM_DISABLE_PERSONALITY=true

RUN apt update -y && apt install -y \
    git \
    wget \
    lsb-release \
    software-properties-common \
    gpg \
    clang \
    clang-18 \
    libc++-18-dev \
    libc++abi-18-dev \
    ca-certificates \
    sudo

RUN if [ -f /etc/alternatives/cc ]; then update-alternatives --remove-all cc; fi && \
    if [ -f /etc/alternatives/c++ ]; then update-alternatives --remove-all c++; fi && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang++-18 500 && \
    update-alternatives --set cc /usr/bin/clang++-18 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-18 500 && \
    update-alternatives --set c++ /usr/bin/clang++-18

WORKDIR /mnt/project

ARG TAG_NAME="hhvm-next"
ARG HHVM_VERSION_MAJOR=6
ARG HHVM_VERSION_MINOR=80
ARG HHVM_VERSION_PATCH=0
ARG HHVM_BRANCH_NAME=master
ENV VERSION="$HHVM_VERSION_MAJOR.$HHVM_VERSION_MINOR.$HHVM_VERSION_PATCH"

RUN git clone --recurse-submodules -b $HHVM_BRANCH_NAME --single-branch https://github.com/hershel-theodore-layton/hhvm hhvm

WORKDIR /mnt/project/hhvm

RUN sed "s/MAJOR 6/MAJOR $HHVM_VERSION_MAJOR/" -i hphp/runtime/version.h && \
    sed "s/MINOR 79/MINOR $HHVM_VERSION_MINOR/" -i hphp/runtime/version.h && \
    sed "s/PATCH 0/PATCH $HHVM_VERSION_PATCH/" -i hphp/runtime/version.h && \
    sed "s/-dev//" -i hphp/runtime/version.h

# If you get a build error, try compiling with fewer threads. This makes reading
# the error messages a lot easier. By default, the build uses all the threads.
# RUN sed 's#parallel=\$(grep -E -c '\''\^processor'\'' /proc/cpuinfo)#parallel=1#' -i ci/bin/make-debianish-package

# This is a workaround added in February 2026. The build deps are missing this package.
# If you can build hhvm 26.2.0+ without this line, remove it.
RUN apt-get install -y libgoogle-glog-dev

RUN ci/bin/make-debianish-package