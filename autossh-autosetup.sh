#!/bin/sh

# Copyright 2019 Emir Turkes
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Sets up an AutoSSH reverse SSH tunnel on the host
# $1 is the IP address of the client
# $2 is the client's SSH port
# $3 is the host's SSH port

cron_string="@reboot sudo -u autossh bash -c '/usr/bin/autossh -M 0 -f autossh@$1 -p $2 -N -o \"ExitOnForwardFailure=yes\" -o \"ServerAliveInterval 60\" -o \"ServerAliveCountMax 3\" -R $3:localhost:$2'"

sudo apt install -y openssh-server autossh \
    && sudo sed -i "s/Port\ 22/Port\ $2/g" /etc/ssh/sshd_config \
    && sudo ufw enable \
    && sudo ufw allow $2/tcp \
    && sudo useradd -m -s /sbin/nologin autossh \
    && sudo -H -u autossh -s bash -c 'ssh-keygen -t ed25519' \
    && sudo -H -u autossh -s bash -c "ssh-copy-id $1 -p $2" \
    && sudo crontab -l | sudo tee /tmp/tmp_crontab \
    && echo $cron_string | sudo tee -a /tmp/tmp_crontab \
    && sudo crontab /tmp/tmp_crontab
