#!/bin/sh

set -eux -o pipefail

uptime && date

#### Configure System to handle Docker capabilities

# Enable swap accounting for containers
sed -i 's/quiet/quiet cgroup_enable=memory swapaccount=1/' /boot/extlinux.conf


### Install Docker
apk --no-cache add docker py-pip docker-bash-completion

service docker stop
addgroup root docker
addgroup "${BASE_USER}" docker
service docker start
rc-update add docker boot

# Enable both TCP and Unix socket for Docker daemon
sed -i 's|command="${DOCKERD_BINARY:-/usr/bin/dockerd}"|DOCKER_OPTS="-H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375"\ncommand="${DOCKERD_BINARY:-/usr/bin/dockerd}"|' /etc/init.d/docker

### Install Docker-compose
pip install --no-cache-dir --upgrade pip
pip install --no-cache-dir "docker-compose"

### Reboot now
reboot now
exit 0
