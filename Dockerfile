# Use the latest official base image
FROM ubuntu:22.04
LABEL maintainer="Sohaib"
LABEL description="Development container with DevOps tools"

ENV DEBIAN_FRONTEND=noninteractive

# Create the non-root user and set up home directory early
RUN useradd -ms /bin/bash devuser && \
    mkdir -p /home/devuser && chown -R devuser:devuser /home/devuser

    # Add devuser to the docker group to allow it to use Docker inside the container
RUN groupadd -r docker && usermod -aG docker devuser

# Install base tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    curl wget zip unzip git vim nano \
    net-tools iputils-ping dnsutils \
    build-essential \
    python3 python3-pip python3-venv \
    gnupg2 jq htop tree \
    docker.io docker-compose \
    openjdk-11-jdk \
    ansible \
    sshpass \
    nodejs \
    make \
    nginx \
    jq \
    fzf \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install common tools
RUN curl -fsSL https://aka.ms/InstallAzureCLIDeb | bash && \
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && rm -rf awscliv2.zip ./aws && \
    curl -sLo kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/ && \
    curl -sLo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
    chmod +x skaffold && mv skaffold /usr/local/bin/


# Install Ctop
RUN CTOP_VERSION=$(curl -s https://api.github.com/repos/bcicen/ctop/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/') && \
    curl -fsSL -o /usr/local/bin/ctop "https://github.com/bcicen/ctop/releases/download/v${CTOP_VERSION}/ctop-${CTOP_VERSION}-linux-amd64" && \
    chmod +x /usr/local/bin/ctop


# Install Python 3 Tkinter
RUN apt-get update && apt-get install -y python3-tk


# Install kube-shell and fix PyYAML version
RUN pip3 install kube-shell PyYAML==5.3.1

# Install Terraform using the official HashiCorp repository
RUN wget -qO - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform

# Install PowerShell
RUN wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && apt-get install -y powershell && \
    rm packages-microsoft-prod.deb

# Install Vim Plug for devuser
USER devuser
RUN mkdir -p /home/devuser/.vim/autoload && \
    curl -fLo /home/devuser/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    chown -R devuser:devuser /home/devuser/.vim

# Switch back to root user for the remaining commands
USER root

# Install Go
RUN GO_VERSION=$(curl -s https://go.dev/dl/ | grep -oP 'go\d+\.\d+\.\d+' | head -1) && \
    curl -sLo go.tar.gz "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz" && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz
ENV PATH="/usr/local/go/bin:$PATH"

# Install K9s
RUN wget -O k9s.deb https://github.com/derailed/k9s/releases/download/v0.32.7/k9s_linux_amd64.deb && \
    apt install -y ./k9s.deb && rm k9s.deb

# Install k8sgpt - AI-powered Kubernetes troubleshooting tool
RUN set -eux; \
    K8SGPT_VERSION=$(curl -s https://api.github.com/repos/k8sgpt-ai/k8sgpt/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/') && \
    echo "Installing k8sgpt version: $K8SGPT_VERSION" && \
    curl -fSL -o k8sgpt_amd64.deb "https://github.com/k8sgpt-ai/k8sgpt/releases/download/v${K8SGPT_VERSION}/k8sgpt_amd64.deb" && \
    dpkg -i k8sgpt_amd64.deb && \
    rm -f k8sgpt_amd64.deb && \
    k8sgpt version




# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && ./get_helm.sh && rm get_helm.sh

# Install kubectx and kubens
RUN curl -sLo kubectx https://github.com/ahmetb/kubectx/releases/latest/download/kubectx && \
    chmod +x kubectx && mv kubectx /usr/local/bin/ && \
    curl -sLo kubens https://github.com/ahmetb/kubectx/releases/latest/download/kubens && \
    chmod +x kubens && mv kubens /usr/local/bin/

# Ensure ~/.bashrc exists if it's missing
RUN echo 'if [ ! -f ~/.bashrc ]; then cp /etc/skel/.bashrc ~/.bashrc; fi' >> /home/devuser/.bashrc

# Set non-root user
USER devuser
WORKDIR /workspace

# Set default shell and load .bashrc on startup
CMD ["/bin/bash", "-c", "[ -f ~/.bashrc ] || cp /etc/skel/.bashrc ~/.bashrc; source ~/.bashrc && exec bash"]
