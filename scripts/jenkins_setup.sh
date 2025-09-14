#!/bin/bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install -y fontconfig openjdk-17-jre
sudo apt-get install -y jenkins
sudo apt-get install -y unrar

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl stop jenkins
sudo unrar x -o+ /tmp/jenkins/jenkins1.rar /var/lib/jenkins/
sudo unrar x -o+ /tmp/jenkins/plugins/plugins1.rar /var/lib/jenkins/plugins/
sudo unrar x -o+ /tmp/jenkins/plugins/plugins2.rar /var/lib/jenkins/plugins/
sudo adduser jenkins docker

sudo cp /tmp/terraform_gcp /var/lib/jenkins/terraform_gcp
sudo chown -R jenkins:jenkins /var/lib/jenkins
sudo chmod 600 /var/lib/jenkins/terraform_gcp
sudo systemctl start jenkins
sudo systemctl enable jenkins