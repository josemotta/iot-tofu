## To completely uninstall Docker from Raspberry Pi OS, follow these steps:

### Identify installed Docker packages.

    dpkg -l | grep -i docker

This command lists all installed packages containing "docker" in their name.

### Remove Docker Engine, CLI, and Containerd packages:

    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io

This command purges the main Docker components.

### Remove any lingering Docker-related packages.

    sudo apt-get autoremove -y --purge docker-engine docker docker.io docker-ce

This command removes any remaining dependencies that are no longer needed.

### Remove Docker data (images, containers, volumes, and configurations):

Caution: This step will permanently delete all your Docker data. Ensure you have backed up any necessary data before proceeding.

    sudo rm -rf /var/lib/docker /etc/docker
    sudo rm /etc/apparmor.d/docker

### Remove the Docker group.

    sudo groupdel docker

### Remove the Docker socket.

    sudo rm -rf /var/run/docker.sock

### Verify uninstallation.

    docker --version

If Docker is completely uninstalled, this command should return an error indicating that docker is not found.
