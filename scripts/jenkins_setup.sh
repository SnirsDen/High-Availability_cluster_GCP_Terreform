#!/bin/bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install -y fontconfig openjdk-17-jre
sudo apt-get install -y jenkins
sudo apt-get install -y unrar

sudo mkdir -p /etc/systemd/system/jenkins.service.d
sudo echo -e "[Service]\nEnvironment=\"JAVA_OPTS=\${JAVA_OPTS} -Djenkins.install.runSetupWizard=false\"" | sudo tee /etc/systemd/system/jenkins.service.d/override.conf
sudo systemctl daemon-reload
sudo -u jenkins mkdir -p /var/lib/jenkins/init.groovy.d
sudo mv /tmp/jenkins/01-admin.groovy /var/lib/jenkins/init.groovy.d
sudo systemctl restart jenkins
sudo chmod +x /tmp/jenkins/setup.sh
sudo ./tmp/jenkins/setup.sh

sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl stop jenkins
sudo adduser jenkins docker

sudo mv /tmp/jenkins/jobs /var/lib/jenkins/
sudo mv /tmp/jenkins/secrets/* /var/lib/jenkins/secrets
sudo mv /tmp/jenkins/credentials.xml /var/lib/jenkins
sudo unrar x -o+ /tmp/jenkins/workspace.rar /var/lib/jenkins/workspace
sudo cp /tmp/terraform_gcp /var/lib/jenkins/terraform_gcp
sudo chown -R jenkins:jenkins /var/lib/jenkins
sudo chmod 600 /var/lib/jenkins/terraform_gcp
sudo systemctl start jenkins
sudo systemctl enable jenkins