#!/bin/bash

apt-get update
apt-get install -y curl apt-transport-https vim openssh-server
apt-get install sshpass -y

swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo 'root:senha' | chpasswd
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh
