FROM ubuntu:bionic-20200112

ENV KUSTOMIZE_VER 3.5.3

WORKDIR /tmp

RUN apt-get update && \
    apt-get install -y curl ca-certificates && \
    mkdir /git

# Install Kustomize
RUN curl -sSL -o kustomize.tar.gz \
    "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VER}/kustomize_v${KUSTOMIZE_VER}_linux_amd64.tar.gz" && \
    tar xvzf kustomize.tar.gz && \
    chmod +x kustomize && \
    mv kustomize /usr/local/bin/kustomize

# Cleanup
RUN apt-get --purge -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /git
ENTRYPOINT []
CMD ["/usr/bin/tail", "-f", "/dev/null"]
