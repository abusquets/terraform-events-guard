
#!/Bin/bash

# Define log file
LOG_FILE="/tmp/setup_k3s.log"

# Check that sufficient arguments have been provided
if [ "$#" -ne 2 ]; then
  echo "Using: $0 <PUBLIC_IP> <K3S_TOKEN>" | tee -a $LOG_FILE
  exit 1
fi


PUBLIC_IP=$1
K3S_TOKEN=$2


# Write to the log file
echo "[$(date)] setup_k3s init ..." | tee -a $LOG_FILE
echo "[$(date)] PUBLIC_IP: $PUBLIC_IP" | tee -a $LOG_FILE
echo "[$(date)] K3S_TOKEN: $K3S_TOKEN" | tee -a $LOG_FILE

echo "[$(date)] Set K3s amb PUBLIC_IP=$PUBLIC_IP and K3S_TOKEN=$K3S_TOKEN" | tee -a $LOG_FILE

sudo mkdir -p /opt/docker-app/k3s

# Install Kubernetes-client
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install Kubernetes-server
# https://docs.k3s.io/installation/configuration#installation-script-options
sudo curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san ${PUBLIC_IP}" sh -s - \
    --write-kubeconfig-mode 644 \
    --write-kubeconfig=/opt/docker-app/kubeconfig.yaml \
    --cluster-init \
    --disable traefik \
    --token "${K3S_TOKEN}"

sudo bash -c 'echo "KUBECONFIG=/opt/docker-app/kubeconfig.yaml" >> /etc/environment'


echo "[$(date)] setup_k3s finished." | tee -a $LOG_FILE