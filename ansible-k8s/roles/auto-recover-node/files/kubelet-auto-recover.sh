#!/bin/bash

MASTER_IP="192.168.0.170"
KUBECONFIG="/etc/kubernetes/kubelet.conf"

while true; do
    # Testa se kubelet está ativo
    systemctl is-active --quiet kubelet
    if [ $? -ne 0 ]; then
        systemctl restart kubelet
    fi

    # Testa se node está registrado e Ready
    if command -v kubectl >/dev/null 2>&1; then
        kubectl --kubeconfig=$KUBECONFIG get node $(hostname) \
            | grep -q "Ready"
        if [ $? -ne 0 ]; then
            echo "$(date) - Node NotReady, reiniciando kubelet e containerd..."
            systemctl restart containerd
            systemctl restart kubelet
        fi
    fi

    sleep 60
done
