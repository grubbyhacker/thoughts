FROM ubuntu:22.04

ARG HUGO_VERSION=0.163.3
ARG PANDOC_VERSION=3.10
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    fonts-texgyre \
    lmodern \
    make \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    fonts-dejavu \
  && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  case "${TARGETARCH:-amd64}" in \
    amd64) hugo_arch="linux-amd64" ;; \
    arm64) hugo_arch="linux-arm64" ;; \
    *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
  esac; \
  curl -fsSL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_${hugo_arch}.tar.gz" -o /tmp/hugo.tar.gz; \
  tar -xzf /tmp/hugo.tar.gz -C /usr/local/bin hugo; \
  rm /tmp/hugo.tar.gz; \
  curl -fsSL "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-${TARGETARCH:-amd64}.tar.gz" -o /tmp/pandoc.tar.gz; \
  tar -xzf /tmp/pandoc.tar.gz -C /tmp; \
  cp "/tmp/pandoc-${PANDOC_VERSION}/bin/pandoc" /usr/local/bin/pandoc; \
  rm -rf /tmp/pandoc.tar.gz "/tmp/pandoc-${PANDOC_VERSION}"; \
  hugo version; \
  pandoc --version | head -n 1; \
  xelatex --version | head -n 1
