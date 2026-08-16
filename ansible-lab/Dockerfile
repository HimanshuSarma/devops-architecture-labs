FROM ubuntu:22.04

# Install SSH server, Python, and sudo
RUN apt-get update && apt-get install -y \
    openssh-server \
    python3 \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH daemon
RUN mkdir /var/run/sshd

# 1. FIX: Turn on password authentication
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 2. FIX: Disable the PAM restriction that blocks container password logins
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# Create an 'ubuntu' user with password 'password' and give sudo permissions
RUN useradd -rm -d /home/ubuntu -s /bin/bash -G sudo -u 1000 ubuntu
RUN echo 'ubuntu:password' | chpasswd

# 1. Write the rule into a dedicated separate file
RUN echo '%sudo ALL=(ALL) NOPASSWD: ALL' > /tmp/sudo_rule && \
    # 2. Validate just this specific file to ensure perfect syntax
    /usr/sbin/visudo -cf /tmp/sudo_rule && \
    # 3. Securely move it to the drop-in directory with correct permissions (0440)
    mv /tmp/sudo_rule /etc/sudoers.d/sudo_rule && \
    chmod 0440 /etc/sudoers.d/sudo_rule

# Set up SSH directory for the user
RUN mkdir -p /home/ubuntu/.ssh && chown ubuntu:root /home/ubuntu/.ssh

# Expose SSH port
EXPOSE 22

# Start SSH service when container starts
CMD ["/usr/sbin/sshd", "-D"]