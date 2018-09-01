#!/bin/bash

SSHPORT=${1:-22}
USER=${2:-ec2-user}
PASSWORD=${3:-changeit}

apt-get update
apt-get install sudo

# Login User
adduser $USER --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "$USER:$PASSWORD" | chpasswd

mkdir /home/$USER/.ssh
cp ~/.ssh/authorized_keys /home/$USER/.ssh/
chown $USER:$USER /home/$USER/.ssh/
chown $USER:$USER /home/$USER/.ssh/authorized_keys

# OpenSSH Rules
grep -q "ChallengeResponseAuthentication" /etc/ssh/sshd_config \
    && sed -i "/^[^#]*ChallengeResponseAuthentication[[:space:]]yes.*/c\ChallengeResponseAuthentication no" /etc/ssh/sshd_config \
    || echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config

grep -q "^[^#]*PasswordAuthentication" /etc/ssh/sshd_config \
    && sed -i "/^[^#]*PasswordAuthentication[[:space:]]yes/c\PasswordAuthentication no" /etc/ssh/sshd_config \
    || echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

grep -q "^[^#]*Port" /etc/ssh/sshd_config \
    && sed -i "/^[^#]*Port[[:space:]]22/c\Port $SSHPORT" /etc/ssh/sshd_config \
    || echo "Port $SSHPORT" >> /etc/ssh/sshd_config

sed -i '/^.*PermitRootLogin.*$/c\PermitRootLogin no' /etc/ssh/sshd_config

# Firewall Rules

iptables -A INPUT -i eth0 -p tcp --dport $SSHPORT -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport $SSHPORT -m state --state ESTABLISHED -j ACCEPT

# Requires Terraform to work through private address
iptables -A INPUT -i eth1 -p tcp --dport $SSHPORT -m state --state NEW,ESTABLISHED -j REJECT

iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# setup docker for debian

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates wget software-properties-common
wget https://download.docker.com/linux/debian/gpg 
sudo apt-key add gpg
echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee -a /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-cache policy docker-ce
sudo apt-get -y install docker-ce
sudo systemctl start docker
sudo systemctl enable docker
sudo groupadd docker
sudo usermod -aG docker $USER

sudo adduser $USER sudo

service ssh restart


