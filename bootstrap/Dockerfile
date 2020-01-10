FROM gcr.io/cloud-builders/gcloud-slim

ENV TERRAFORM_VER 0.12.19
ENV TERRAGRUNT_VER 0.21.10
ENV KUSTOMIZE_VER 3.5.3
ENV ARGO_ROLLOUTS_VER 0.6.0
ENV ARGOCD_VER 1.3.6
ENV TF_PROVIDER_K8S_VER 0.5.0

WORKDIR /tmp

RUN apt-get update && \
    apt-get install -y unzip curl ca-certificates && \
    gcloud -q components install beta kubectl && \
    gcloud -q components update && \
    mkdir /git

# Install Kustomize
RUN curl -sSL -o kustomize.tar.gz \
    "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VER}/kustomize_v${KUSTOMIZE_VER}_linux_amd64.tar.gz" && \
    tar xvzf kustomize.tar.gz && \
    chmod +x kustomize && \
    mv kustomize /usr/local/bin/kustomize

# Install Terraform/Terragrunt
RUN curl -sSL -o terraform.zip \
    "https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip" && \
    unzip terraform.zip && \
    curl -sSL -o terragrunt \
    "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VER}/terragrunt_linux_amd64" && \
    chmod +x terraform terragrunt && \
    mv terraform terragrunt /usr/local/bin/

# Download Terraform custom providers
RUN curl -sSL -o terraform-provider-k8s.tar.gz \
    "https://github.com/banzaicloud/terraform-provider-k8s/releases/download/v${TF_PROVIDER_K8S_VER}/terraform-provider-k8s_${TF_PROVIDER_K8S_VER}_linux_amd64.tar.gz" && \
    tar xvf terraform-provider-k8s.tar.gz && \
    chmod +x terraform-provider-k8s && \
    mv terraform-provider-k8s /usr/local/sbin/
COPY terraformrc "$HOME/.terraformrc"

# Install Argo CD cli
RUN curl -sSL -o /usr/local/bin/argocd \
    "https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VER}/argocd-linux-amd64" && \
    chmod +x /usr/local/bin/argocd

# Install Argo Rollouts kubectl plugin
RUN curl -sSL -o /usr/local/bin/kubectl-argo-rollouts \
    "https://github.com/argoproj/argo-rollouts/releases/download/v${ARGO_ROLLOUTS_VER}/kubectl-argo-rollouts-linux-amd64" && \
    chmod +x /usr/local/bin/kubectl-argo-rollouts

# Cleanup
RUN apt-get remove --purge -y unzip curl && \
    apt-get --purge -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# COPY kustomize.bash /opt/kustomize.bash
# ENTRYPOINT ["/opt/kustomize.bash"]

WORKDIR /git
ENTRYPOINT []
CMD ["/usr/bin/tail", "-f", "/dev/null"]
