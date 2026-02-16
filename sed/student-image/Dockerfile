FROM rockylinux:9

RUN dnf -y update && \
    dnf -y --allowerasing install git openssh-server sudo cronie curl wget \
    net-tools \
      iproute \
      iputils \
      tcpdump \
      bind-utils \
      procps-ng \
      lsof \
      which \
    && \
    mkdir -p /var/run/sshd /run/sshd

RUN useradd -m -s /bin/bash student && \
    echo "student:student123" | chpasswd && \
    usermod -aG wheel student

RUN echo "root:password" | chpasswd

# Configure SSH for Rocky Linux
RUN sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Generate SSH host keys
RUN ssh-keygen -A

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
