FROM debian:bullseye

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    USER=pi \
    HOME=/home/pi \
    TESTING_ENV=true

# Create user, install dependencies, and set up directories in a single layer
RUN useradd -m -s /bin/bash pi && \
    apt-get update && \
    apt-get install -y \
        apt-transport-https \
        gnupg \
        gpg \
        sudo \
        systemd \
        systemd-sysv \
        wget \
    && echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections && \
    echo "pi ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /etc/apt/keyrings /etc/apt/sources.list.d /etc/mopidy && \
    chown -R pi:pi /etc/apt/keyrings /etc/apt/sources.list.d /etc/mopidy && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy and prepare installation script
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