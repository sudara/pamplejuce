FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && sudo apt install -y
  git \
  clang-11 \
  cmake \
  ninja-build \
  pkg-config \
  openssh-client \
  libjack-jackd2-dev \
  ladspa-sdk \
  libcurl4-openssl-dev  \
  libfreetype6-dev \
  libx11-dev  \
  libxcomposite-dev  \
  libxcursor-dev  \
  libxcursor-dev  \
  libxext-dev  \
  libxinerama-dev  \
  libxrandr-dev \
  libxrender-dev \
  libwebkit2gtk-4.0-dev \
  libglu1-mesa-dev  \
  mesa-common-dev \
  xpra \
  xserver-xorg-video-dummy
  
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang-14 100
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-14 100