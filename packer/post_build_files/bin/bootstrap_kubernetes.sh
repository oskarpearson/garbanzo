#!/bin/bash

set -e
set -x
set -o pipefail

SSL_KEY_BUCKET=$(cat /opt/garbanzo/etc/ssl_key_bucket)
MASTER_COUNT=$(cat /opt/garbanzo/etc/master_count)
DOMAIN_NAME=$(cat /opt/garbanzo/etc/domain_name)
SSL_DIR=/opt/garbanzo/ssl
INTERNAL_IP=$(curl -sS http://169.254.169.254/latest/meta-data/local-ipv4)

# copied from etcd init
declare -a ETCD_CLUSTER_HOSTS
for i in $(seq 1 $MASTER_COUNT); do
  ETCD_CLUSTER_HOSTS[i]="master-${i}=https://master-${i}-priv.${DOMAIN_NAME}:2380"
done
ETCD_CLUSTER_LIST=$(IFS=, ; echo "${ETCD_CLUSTER_HOSTS[*]}")

# download the bootstrap token
sudo mkdir -p /var/lib/kubernetes/
sudo aws s3 cp "s3://${SSL_KEY_BUCKET}/token.csv" /var/lib/kubernetes/token.csv

# create the systemd init file for the API server
cat > kube-apiserver.service <<EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/garbanzo_docs_url_when_we_have_one?

[Service]
ExecStart=/usr/bin/kube-apiserver \\
  --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/lib/audit.log \\
  --authorization-mode=RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=${SSL_DIR}/ca.pem \\
  --enable-swagger-ui=true \\
  --etcd-cafile=${SSL_DIR}/ca.pem \\
  --etcd-certfile=${SSL_DIR}/local-server.pem \\
  --etcd-keyfile=${SSL_DIR}/local-server-key.pem \\
  --etcd-servers=${ETCD_CLUSTER_LIST} \\
  --event-ttl=1h \\
  --experimental-bootstrap-token-auth \\
  --insecure-bind-address=0.0.0.0 \\
  --kubelet-certificate-authority=${SSL_DIR}/ca.pem \\
  --kubelet-client-certificate=${SSL_DIR}/local-server.pem \\
  --kubelet-client-key=${SSL_DIR}/local-server-key.pem \\
  --kubelet-https=true \\
  --runtime-config=rbac.authorization.k8s.io/v1alpha1 \\
  --service-account-key-file=${SSL_DIR}/ca-key.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=${SSL_DIR}/local-server.pem \\
  --tls-private-key-file=${SSL_DIR}/local-server-key.pem \\
  --token-auth-file=/var/lib/kubernetes/token.csv \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# download kubernetes binaries
wget https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/linux/amd64/kube-apiserver
wget https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/linux/amd64/kube-controller-manager
wget https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/linux/amd64/kube-scheduler
wget https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/linux/amd64/kubectl
chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/bin/

# start and check API server status
sudo mv kube-apiserver.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable kube-apiserver
sudo systemctl start kube-apiserver
sudo systemctl status kube-apiserver --no-pager







CLUSTER_NAME=$(cat /opt/garbanzo/etc/cluster_name)
SSL_DIR=/opt/garbanzo/ssl
INTERNAL_IP=$(curl -sS http://169.254.169.254/latest/meta-data/local-ipv4)

cat > kube-controller-manager.service <<EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/garbanzo_docs_url_when_we_have_one?

[Service]
ExecStart=/usr/bin/kube-controller-manager \\
  --address=0.0.0.0 \\
  --allocate-node-cidrs=true \\
  --cluster-cidr=10.200.0.0/16 \\
  --cluster-name=${CLUSTER_NAME} \\
  --cluster-signing-cert-file=${SSL_DIR}/ca.pem \\
  --cluster-signing-key-file=${SSL_DIR}/ca-key.pem \\
  --leader-elect=true \\
  --master=http://${INTERNAL_IP}:8080 \\
  --root-ca-file=${SSL_DIR}/ca.pem \\
  --service-account-private-key-file=${SSL_DIR}/ca-key.pem \\
  --service-cluster-ip-range=10.32.0.0/16 \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo mv kube-controller-manager.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable kube-controller-manager
sudo systemctl start kube-controller-manager
sudo systemctl status -l kube-controller-manager --no-pager






INTERNAL_IP=$(curl -sS http://169.254.169.254/latest/meta-data/local-ipv4)

cat > kube-scheduler.service <<EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/garbanzo_docs_url_when_we_have_one?

[Service]
ExecStart=/usr/bin/kube-scheduler \\
  --leader-elect=true \\
  --master=http://${INTERNAL_IP}:8080 \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo mv kube-scheduler.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable kube-scheduler
sudo systemctl start kube-scheduler
sudo systemctl status kube-scheduler --no-pager
