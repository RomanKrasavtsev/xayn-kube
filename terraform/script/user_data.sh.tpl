#!/bin/bash

# Install docker
apt-get update

apt-get install ca-certificates curl -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$${UBUNTU_CODENAME:-$$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Install minikube
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

# Install git
apt install -y git

# Install helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install helm

# Create user
USER="minikube"
adduser $USER
passwd -d $USER || true
groupadd docker
usermod -aG docker $USER && newgrp docker
sudo -u $USER bash <<'EOF'
# Start minikube
minikube start --driver=docker && minikube kubectl -- get pods -A
echo 'alias kubectl="minikube kubectl --"' >> ~/.bashrc

# Install traefik
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm install traefik traefik/traefik \
  --namespace kube-system \
  --set hostNetwork=true \
  --set service.type=ClusterIP \
  --set persistence.enabled=true \
  --set-string additionalArguments[0]="--entrypoints.web.address=:80" \
  --set-string additionalArguments[1]="--entrypoints.websecure.address=:443" \
  --set-string additionalArguments[2]="--certificatesresolvers.le.acme.email=mr.krasavtsev@gmail.com" \
  --set-string additionalArguments[3]="--certificatesresolvers.le.acme.storage=/data/acme.json" \
  --set-string additionalArguments[4]="--certificatesresolvers.le.acme.httpchallenge.entrypoint=web" \
  --set-string additionalArguments[5]="--certificatesresolvers.le.acme.httpchallenge=true"
EOF

# Update DNS records
IP_ADDRESS=$(curl ifconfig.me)
echo "$IP_ADDRESS"
echo "${duckdns_token}"
curl "https://www.duckdns.org/update?domains=dev-xayn&token=${duckdns_token}&ip=$IP_ADDRESS"
curl "https://www.duckdns.org/update?domains=prod-xayn&token=${duckdns_token}&ip=$IP_ADDRESS"

# Install nginx-full
apt install -y nginx-full
rm /etc/nginx/sites-enabled/default
MINIKUBE_IP=$(su - minikube -c "minikube ip")
tee -a /etc/nginx/nginx.conf > /dev/null <<EOF

stream {
    upstream minikube_https {
        server $MINIKUBE_IP:443;
    }

    server {
        listen 443;
        proxy_pass minikube_https;
    }

    upstream minikube_http {
        server $MINIKUBE_IP:80;
    }

    server {
        listen 80;
        proxy_pass minikube_http;
    }
}
EOF
systemctl reload nginx

sudo -u $USER bash <<'EOF'
# Clone repo
git clone https://github.com/RomanKrasavtsev/xayn-kube.git ~/git

# Deploy dev
helm install app-dev ~/git/app -f ~/git/app/values-dev.yaml

# Deploy prod
helm install app-prod ~/git/app -f ~/git/app/values-prod.yaml
EOF
