#!/bin/bash

apt-get install -y ansible

chmod +x /root/ansible-docker/*
chmod +x /root/ansible-k8s/*

ansible-playbook -i /root/ansible-docker/inventory.ini /root/ansible-docker/playbook.yml
ansible-playbook -i /root/ansible-k8s/inventory.ini /root/ansible-k8s/playbook.yml
