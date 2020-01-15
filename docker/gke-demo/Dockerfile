FROM golang:alpine AS terraform-bundler-builder

RUN apk --no-cache add git unzip && \
    go get -d -v github.com/hashicorp/terraform && \
    go install ./src/github.com/hashicorp/terraform/tools/terraform-bundle

COPY terraform-bundle.hcl .

# Bundle Terraform standard plugins and Terraform itself since Hashicorp servers
# are so unreliable
RUN terraform-bundle package terraform-bundle.hcl && \
    mkdir -p terraform-bundle && \
    unzip -d terraform-bundle terraform_*.zip

################################################################

FROM gcr.io/cloud-builders/gcloud-slim

ENV TERRAGRUNT_VER 0.21.10
ENV KUSTOMIZE_VER 3.5.3
ENV ARGO_ROLLOUTS_VER 0.6.0
ENV ARGOCD_VER 1.3.6
ENV TF_PROVIDER_K8S_VER 0.5.0
ENV TF_PROVIDER_GITFILE_VER 1.0

WORKDIR /tmp

RUN apt-get update && \
    apt-get install -y unzip curl ca-certificates jq vim-tiny && \
    gcloud -q components install beta kubectl && \
    gcloud -q components update && \
    mkdir -p /git /root/.terraform.d/plugins/linux_amd64

# Install Terraform
COPY --from=terraform-bundler-builder /go/terraform-bundle/terraform \
    /usr/local/bin/

# Install Terraform plugins
COPY --from=terraform-bundler-builder /go/terraform-bundle/terraform-provider-* \
    /root/.terraform.d/plugins/linux_amd64/

# Install Kustomize
RUN curl -sSL -o kustomize.tar.gz \
    "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VER}/kustomize_v${KUSTOMIZE_VER}_linux_amd64.tar.gz" && \
    tar xvzf kustomize.tar.gz && \
    chmod +x kustomize && \
    mv kustomize /usr/local/bin/kustomize

# Install Terragrunt
RUN curl -sSL -o /usr/local/bin/terragrunt \
    "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VER}/terragrunt_linux_amd64" && \
    chmod +x /usr/local/bin/terragrunt

# Install Terraform "k8s" provider
RUN curl -sSL -o terraform-provider-k8s.tar.gz \
    "https://github.com/banzaicloud/terraform-provider-k8s/releases/download/v${TF_PROVIDER_K8S_VER}/terraform-provider-k8s_${TF_PROVIDER_K8S_VER}_linux_amd64.tar.gz" && \
    tar xvf terraform-provider-k8s.tar.gz && \
    chmod +x terraform-provider-k8s && \
    mv terraform-provider-k8s /root/.terraform.d/plugins/linux_amd64

# Install Terraform "gitfile" provider
RUN curl -sSL -o /root/.terraform.d/plugins/linux_amd64/terraform-provider-gitfile \
    "https://github.com/ilya-lesikov/terraform-provider-gitfile/releases/download/${TF_PROVIDER_GITFILE_VER}/terraform-provider-gitfile" && \
    chmod +x /root/.terraform.d/plugins/linux_amd64/terraform-provider-gitfile

# Install Argo CD cli
RUN curl -sSL -o /usr/local/bin/argocd \
    "https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VER}/argocd-linux-amd64" && \
    chmod +x /usr/local/bin/argocd

# Install Argo Rollouts kubectl plugin
RUN curl -sSL -o /usr/local/bin/kubectl-argo-rollouts \
    "https://github.com/argoproj/argo-rollouts/releases/download/v${ARGO_ROLLOUTS_VER}/kubectl-argo-rollouts-linux-amd64" && \
    chmod +x /usr/local/bin/kubectl-argo-rollouts

# Cleanup
RUN apt-get remove --purge -y unzip && \
    apt-get --purge -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /git
ENTRYPOINT []
CMD ["/usr/bin/tail", "-f", "/dev/null"]
