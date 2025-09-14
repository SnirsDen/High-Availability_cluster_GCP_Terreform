resource "google_compute_instance" "monitoring_vm" {
  name         = "monitoring"
  machine_type = "e2-standard-2"
  zone         = "europe-west4-a"
  tags         = ["monitoring", "http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.ssh_key.public_key_openssh}"
    startup-script = templatefile("${path.module}/scripts/monitoring_setup.sh", {
      prod_vm_1_ip      = google_compute_instance.prod_vms[0].network_interface.0.network_ip
      prod_vm_2_ip      = google_compute_instance.prod_vms[1].network_interface.0.network_ip
      dev_vm_1_ip       = google_compute_instance.dev_vms[0].network_interface.0.network_ip
      dev_vm_2_ip       = google_compute_instance.dev_vms[1].network_interface.0.network_ip
      dashboard_content = filebase64("${path.module}/monitoring/my-dashboard.json")
  }) }

  timeouts {
    create = "30m"
    update = "30m"
  }

  provisioner "file" {
    source      = "${path.module}/monitoring/my-dashboard.json"
    destination = "/tmp/my-dashboard.json"

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
      "sudo mkdir -p /opt/monitoring/dashboards",
      "sudo mv /tmp/my-dashboard.json /opt/monitoring/dashboards/",
      "sudo chown ubuntu:ubuntu /opt/monitoring/dashboards/my-dashboard.json"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.ssh_key.private_key_openssh
      host        = self.network_interface[0].access_config[0].nat_ip
      timeout     = "30m"
    }
  }
}

resource "google_compute_firewall" "grafana" {
  name    = "allow-grafana"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["monitoring"]
}

resource "google_compute_firewall" "prometheus" {
  name    = "allow-prometheus"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9090"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["monitoring"]
}

output "monitoring_vm_ip" {
  description = "IP-адрес виртуальной машины мониторинга"
  value       = google_compute_instance.monitoring_vm.network_interface.0.access_config.0.nat_ip
}

output "grafana_url" {
  description = "URL для доступа к Grafana"
  value       = "http://${google_compute_instance.monitoring_vm.network_interface.0.access_config.0.nat_ip}:3000"
}

output "prometheus_url" {
  description = "URL для доступа к Prometheus"
  value       = "http://${google_compute_instance.monitoring_vm.network_interface.0.access_config.0.nat_ip}:9090"
}