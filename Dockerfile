FROM debian:bullseye

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV USER=pi
ENV HOME=/home/pi

# Create pi user and set up home directory
RUN useradd -m -s /bin/bash pi

# Install basic utilities without sudo first
RUN apt-get update && apt-get install -y \
    wget \
    systemd \
    systemd-sysv \
    gpg \
    gnupg \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Install and configure sudo non-interactively
RUN apt-get update && \
    echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections && \
    apt-get install -y sudo && \
    echo "pi ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories with proper permissions
RUN mkdir -p /etc/apt/keyrings && \
    chown -R pi:pi /etc/apt/keyrings && \
    mkdir -p /etc/apt/sources.list.d && \
    chown -R pi:pi /etc/apt/sources.list.d && \
    mkdir -p /etc/mopidy && \
    chown -R pi:pi /etc/mopidy

# Copy installation script
COPY install.sh /home/pi/install.sh
RUN chmod +x /home/pi/install.sh && \
    chown pi:pi /home/pi/install.sh

# Switch to pi user
USER pi
WORKDIR /home/pi

# Expose necessary ports
EXPOSE 3000 6680 8080

# Command to run the installation script
CMD ["/bin/bash", "-c", "./install.sh"] 