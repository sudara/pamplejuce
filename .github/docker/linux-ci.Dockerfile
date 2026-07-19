# Linux CI build environment for Pamplejuce-family projects.
# Based on jammy (Ubuntu 22.04) so plugins built here run on any distro with glibc >= 2.35.
# Rebuilt by .github/workflows/linux-ci-image.yml when this file changes (or via workflow_dispatch).
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y wget ca-certificates gnupg git git-lfs curl unzip pkg-config file binutils zstd jq openssl xvfb \
 && wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor > /usr/share/keyrings/oneapi-archive-keyring.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" > /etc/apt/sources.list.d/oneAPI.list \
 && wget -O- https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor > /usr/share/keyrings/llvm.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/llvm.gpg] http://apt.llvm.org/jammy/ llvm-toolchain-jammy-18 main" > /etc/apt/sources.list.d/llvm.list \
 && apt-get update \
 && apt-get install -y clang-18 lld-18 ninja-build libstdc++-12-dev libasound2-dev libjack-jackd2-dev libcurl4-openssl-dev libx11-dev libxinerama-dev libxext-dev libxcomposite-dev libxcursor-dev libxrandr-dev libxrender-dev libfreetype6-dev libfontconfig1-dev libwebkit2gtk-4.1-dev libglu1-mesa-dev mesa-common-dev ladspa-sdk intel-oneapi-ipp-devel \
 && ln -sf /usr/bin/ld.lld-18 /usr/local/bin/ld.lld \
 && rm -rf /var/lib/apt/lists/*

# cmake >= 3.25 (jammy apt has 3.22)
RUN wget -qO- https://github.com/Kitware/CMake/releases/download/v3.31.8/cmake-3.31.8-linux-x86_64.tar.gz | tar xz -C /usr/local --strip-components=1

RUN wget -q https://github.com/mozilla/sccache/releases/download/v0.8.1/sccache-v0.8.1-x86_64-unknown-linux-musl.tar.gz \
 && tar xzf sccache-v0.8.1-x86_64-unknown-linux-musl.tar.gz \
 && mv sccache-v0.8.1-x86_64-unknown-linux-musl/sccache /usr/local/bin/ \
 && rm -rf sccache-v0.8.1-x86_64-unknown-linux-musl*

# JUCE's juceaide bootstraps its own nested cmake configure, which discovers compilers from the
# environment rather than the parent build, so CC/CXX must be env vars here
ENV CC=clang-18 \
    CXX=clang++-18
