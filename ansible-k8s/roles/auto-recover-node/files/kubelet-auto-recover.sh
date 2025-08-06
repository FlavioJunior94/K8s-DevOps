#!/bin/bash
# Script de auto-recuperação do kubelet com monitoramento contínuo
# Log: /var/log/kubelet-auto-recover.log

LOG_FILE="/var/log/kubelet-auto-recover.log"

while true; do
    DATE=$(date '+%Y-%m-%d %H:%M:%S')
    NODE_NAME=$(hostname)

    echo "[$DATE] Verificando estado do kubelet e do node $NODE_NAME..." >> "$LOG_FILE"

    # 1️⃣ Verifica se o kubelet está ativo
    if ! systemctl is-active --quiet kubelet; then
        echo "[$DATE] kubelet está parado. Reiniciando..." >> "$LOG_FILE"
        systemctl restart kubelet
        sleep 20
    fi

    # 2️⃣ Verifica status do node via kubectl
    STATUS=$(kubectl get nodes --no-headers | grep -w "$NODE_NAME" | awk '{print $2}')

    if [[ -z "$STATUS" ]]; then
        echo "[$DATE] Node $NODE_NAME não encontrado no cluster." >> "$LOG_FILE"
    elif [[ "$STATUS" != "Ready" && "$STATUS" != "Ready,SchedulingDisabled" ]]; then
        echo "[$DATE] Node $NODE_NAME está $STATUS. Tentando auto-recuperação..." >> "$LOG_FILE"

        # Reinicia kubelet primeiro
        systemctl restart kubelet
        sleep 30

        # Verifica status novamente
        STATUS=$(kubectl get nodes --no-headers | grep -w "$NODE_NAME" | awk '{print $2}')
        if [[ "$STATUS" != "Ready" && "$STATUS" != "Ready,SchedulingDisabled" ]]; then
            # Verifica se é master ou worker
            if kubectl get nodes --no-headers | grep -w "$NODE_NAME" | grep -q "control-plane"; then
                echo "[$DATE] Master node detectado. Apenas reiniciando serviços..." >> "$LOG_FILE"
                systemctl restart containerd
                systemctl restart kubelet
            else
                echo "[$DATE] Worker node detectado. Resetando e tentando rejoin..." >> "$LOG_FILE"
                kubeadm reset -f
                systemctl restart kubelet
                
                # Executa playbook de rejoin
                ansible-playbook -i /root/K8s-DevOps/ansible-k8s/inventory.ini \
                    /root/K8s-DevOps/ansible-k8s/playbook.yml \
                    --tags auto-rejoin-worker >> "$LOG_FILE" 2>&1
            fi
        fi
    else
        echo "[$DATE] Node $NODE_NAME está saudável (Status: $STATUS)" >> "$LOG_FILE"
    fi

    # 3️⃣ Espera 60 segundos antes de nova checagem
    sleep 60
done
