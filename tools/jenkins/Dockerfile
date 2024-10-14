FROM jenkins/jenkins:2.480-jdk17

# Skip the initial setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Install Jenkins plugins for Kubernetes, GitLab, Docker, and Podman
RUN jenkins-plugin-cli --plugins \
    kubernetes:4292.v11898cf8fa_66 \
    kubernetes-cli:1.12.1 \
    gitlab-plugin:1.9.4 \
    workflow-aggregator:600.vb_57cdd26fdd7 \
    docker-workflow:580.vc0c340686b_54

# Install packages
USER root
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    curl \
    apt-transport-https \
    ca-certificates \
    gnupg2 \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN npm install --global yarn npx

# Install Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh && rm get-docker.sh

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/v1.21.0/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/kubectl

# Install Helm
RUN curl -LO https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz \
    && tar -zxvf helm-v3.6.3-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && rm -rf linux-amd64/ helm-v3.6.3-linux-amd64.tar.gz

# Set Docker and Podman binaries in PATH
ENV PATH=$PATH:/usr/bin/podman:/usr/local/bin/docker

# Switch back to Jenkins user
USER jenkins
