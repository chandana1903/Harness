#!/bin/bash
# Don't use set -e (if one tool fails, continue installing others)

echo "========================================="
echo "  Installing tools on Bastion Server"
echo "  OS: Amazon Linux 2023"
echo "========================================="

# Update system
dnf update -y || yum update -y
dnf install -y unzip jq bc git docker || yum install -y unzip jq bc git docker

# ----------------------------- SSM Agent (pre-installed on AL2023) ---------
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# ----------------------------- Docker -------------------------------------
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# ----------------------------- kubectl ------------------------------------
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install kubectl /usr/local/bin/kubectl
kubectl version --client || true

# ----------------------------- eksctl -------------------------------------
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin/eksctl
eksctl version || true

# ----------------------------- Helm ---------------------------------------
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version || true

# ----------------------------- AWS CLI v2 (pre-installed on AL2023) --------
aws --version || true

# ----------------------------- PostgreSQL ----------------------------------
dnf install -y postgresql15 postgresql15-server || yum install -y postgresql15 postgresql15-server || true
/usr/bin/postgresql-setup --initdb || true
systemctl enable postgresql || true
systemctl start postgresql || true
psql --version || true

# ----------------------------- MariaDB ------------------------------------
dnf install -y mariadb105-server || yum install -y mariadb105-server || true
systemctl enable mariadb || true
systemctl start mariadb || true
mysql --version || true

# ----------------------------- Helm Repos ---------------------------------
helm repo add autoscaler https://kubernetes.github.io/autoscaler || true
helm repo add stable https://charts.helm.sh/stable || true
helm repo add bitnami https://charts.bitnami.com/bitnami || true
helm repo update || true

# ----------------------------- Harness Docker Runner -----------------------
curl -L -o /usr/local/bin/harness-docker-runner https://github.com/harness/harness-docker-runner/releases/download/v0.1.25/harness-docker-runner-linux-amd64
chmod +x /usr/local/bin/harness-docker-runner

# ----------------------------- Trivy (security scanner) -------------------
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin || true

# ----------------------------- SonarQube Scanner --------------------------
curl -L -o /tmp/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
unzip /tmp/sonar-scanner.zip -d /opt/ || true
ln -s /opt/sonar-scanner-*/bin/sonar-scanner /usr/local/bin/sonar-scanner || true
rm -f /tmp/sonar-scanner.zip

# ----------------------------- SonarQube Server (port 9000) ----------------
# Access at: http://BASTION-PUBLIC-IP:9000
# Default login: admin / admin
docker run -d --name sonarqube --restart always -p 9000:9000 sonarqube:lts-community

echo "========================================="
echo "  All tools installed!"
echo "========================================="
