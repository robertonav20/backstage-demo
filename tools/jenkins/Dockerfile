FROM jenkins/jenkins:2.480-jdk17

# Skip the initial setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false -Djenkins.install.SetupWizard.adminInitialApiToken=true

# Install Jenkins plugins for Kubernetes, GitLab, Docker
RUN jenkins-plugin-cli --plugins \
    kubernetes:4292.v11898cf8fa_66 \
    kubernetes-cli:1.12.1 \
    gitlab-plugin:1.9.4 \
    workflow-aggregator:600.vb_57cdd26fdd7 \
    docker-plugin:1.7.0 \
    docker-workflow:580.vc0c340686b_54 \
    credentials

# Install packages
USER root

RUN apt-get update && \
    apt-get install -qyy \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    maven \
    nodejs \
    npm \
    software-properties-common && \
    rm -rf /var/lib/apt/lists/*

RUN npm install --global yarn npx

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/v1.21.0/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/kubectl

# Install Helm
RUN curl -LO https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz \
    && tar -zxvf helm-v3.6.3-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && rm -rf linux-amd64/ helm-v3.6.3-linux-amd64.tar.gz

# Set Docker binaries in PATH
ENV PATH=$PATH:/usr/local/bin/docker

ARG GITLAB_PASSWORD
ARG GITLAB_USER
ARG JENKINS_ADMIN_PASSWORD
ARG JENKINS_ADMIN_USER
ARG JENKINS_FOLDER

ENV GITLAB_PASSWORD=$GITLAB_PASSWORD
ENV GITLAB_USER=$GITLAB_USER
ENV JENKINS_ADMIN_PASSWORD=$JENKINS_ADMIN_PASSWORD
ENV JENKINS_ADMIN_USER=$JENKINS_ADMIN_USER
ENV JENKINS_FOLDER=$JENKINS_FOLDER

# Switch back to Jenkins user
USER jenkins

# Copy Groovy scripts to initialize Jenkins with default credentials and folder
COPY init.groovy.d /usr/share/jenkins/ref/init.groovy.d/