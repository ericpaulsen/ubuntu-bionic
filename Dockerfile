FROM ericpaulsen/ubuntu-bionic-gui:latest

SHELL ["/bin/bash", "-c"]

COPY containerd-pin /etc/apt/preferences.d/

# Install the Docker apt repository
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes ca-certificates
COPY docker-archive-keyring.gpg /usr/share/keyrings/docker-archive-keyring.gpg
COPY docker.list /etc/apt/sources.list.d/docker.list

# Install baseline packages
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
      bash \
      build-essential \
      ca-certificates \
      containerd.io=1.5.11-1 \
      curl \
      docker-ce \
      docker-ce-cli \
      docker-compose-plugin \
      htop \
      locales \
      man \
      python3 \
      python3-pip \
      software-properties-common \
      sudo \
      systemd \
      systemd-sysv \
      unzip \
      vim \
      wget && \
    # Install latest Git using their official PPA
    add-apt-repository ppa:git-core/ppa && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes git

# Enables Docker starting with systemd
RUN systemctl enable docker

# Add docker-compose
RUN curl -L "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

# Add a user `coder` so that you're not developing as the `root` user
RUN useradd coder \
      --create-home \
      --shell=/bin/bash \
      --groups=docker \
      --uid=1000 \
      --user-group && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd

USER coder

COPY ./ubuntu.png /coder/apps/ubuntu.png

RUN sudo chown -R coder /coder/apps

COPY [ "configure", "/coder/configure" ]