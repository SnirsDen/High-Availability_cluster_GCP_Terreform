resource "google_compute_instance" "jenkins" {
  name         = "jenkins"
  machine_type = "e2-standard-2"
  zone         = "europe-west4-a"
  tags         = ["jenkins-server", "http-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-lts"
      size  = 30
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }


  metadata = {
    ssh-keys       = "ubuntu:${tls_private_key.ssh_key.public_key_openssh}"
    startup-script = file("${path.module}/scripts/jenkins_setup.sh")
  }

  provisioner "file" {
    source      = "${path.module}/terraform_gcp"
    destination = "/tmp/terraform_gcp"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.ssh_key.private_key_openssh
      host        = self.network_interface[0].access_config[0].nat_ip
      timeout     = "30m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/jenkins"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.ssh_key.private_key_openssh
      host        = self.network_interface[0].access_config[0].nat_ip
      timeout     = "30m"
    }
  }
  provisioner "file" {
    source      = "${path.module}/jenkins/"
    destination = "/tmp/jenkins/."
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.ssh_key.private_key_openssh
      host        = self.network_interface[0].access_config[0].nat_ip
      timeout     = "30m"
    }
  }

}
resource "google_compute_firewall" "jenkins-port" {
  name    = "jenkins-8080"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jenkins-server", "http-server"]
}

output "jenkins_external_ip" {
  value = google_compute_instance.jenkins.network_interface[0].access_config[0].nat_ip
}