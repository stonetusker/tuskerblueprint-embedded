FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG KAS_VERSION=4.5

RUN apt-get update && apt-get install -y --no-install-recommends \
    bc bison build-essential chrpath cpio curl debianutils diffstat file flex gawk gcc git \
    iproute2 iputils-ping jq locales lz4 make openssh-client python3 python3-pip python3-pexpect \
    python3-subunit socat sudo texinfo unzip wget xz-utils zstd ca-certificates qemu-system-arm \
    qemu-utils rsync skopeo && \
    locale-gen en_US.UTF-8 && \
    python3 -m pip install --break-system-packages --no-cache-dir "kas==${KAS_VERSION}" && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd --gid ${GROUP_ID} builder && \
    useradd --uid ${USER_ID} --gid ${GROUP_ID} --create-home --shell /bin/bash builder && \
    mkdir -p /work /cache/downloads /cache/sstate /artifacts && \
    chown -R builder:builder /work /cache /artifacts

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    USER=builder \
    HOME=/home/builder

COPY --chmod=0755 kas-container-entrypoint /usr/local/bin/kas-container-entrypoint

USER builder
WORKDIR /work
ENTRYPOINT ["/usr/local/bin/kas-container-entrypoint"]
