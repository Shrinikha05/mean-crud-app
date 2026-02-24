#!/bin/bash

dnf update -y

dnf install docker -y
dnf install git -y

dnf install -y curl wget

systemctl start docker
systemctl enable docker


curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

usermod -aG docker ec2-user

cd /home/ec2-user

git clone https://github.com/Shrinikha05/mean-crud-app.git

chown -R ec2-user:ec2-user /home/ec2-user/mean-crud-app

cd mean-crud-app