# Use the latest official Ubuntu image as the base
FROM ubuntu:latest

# Set environment variables to avoid tzdata configuration during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package repository and install necessary packages
RUN apt-get update -y && \
    apt-get install -y git openssh-server default-jdk maven && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure SSH server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd

# Create a user 'jenkins' and set a secure password
RUN useradd -m -s /bin/bash jenkins && \
    echo "jenkins:password" | chpasswd

# Create necessary directories for Jenkins user
RUN mkdir -p /home/jenkins/.m2 /home/jenkins/.ssh && \
    chown -R jenkins:jenkins /home/jenkins/.m2 /home/jenkins/.ssh

# Copy your authorized_keys file for SSH access
COPY .ssh/authorized_keys /home/jenkins/.ssh/authorized_keys

# Set permissions for Jenkins user
RUN chown -R jenkins:jenkins /home/jenkins/.ssh

# Expose SSH port
EXPOSE 22

# Start SSH server
CMD ["/usr/sbin/sshd", "-D"]
