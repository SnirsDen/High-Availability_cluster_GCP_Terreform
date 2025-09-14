provider "google" {
  project = var.project_id
  region  = var.region
}
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_openssh
  filename        = "${path.module}/terraform_gcp"
  file_permission = "0600"
}
resource "local_file" "public_key" {
  content  = tls_private_key.ssh_key.public_key_openssh
  filename = "${path.module}/terraform_gcp.pub"
}
resource "google_compute_instance" "prod_vms" {
  count        = 2
  name         = "prod-${count.index + 1}"
  machine_type = "e2-standard-2"
  zone         = element(var.prod_zones, count.index)
  tags         = ["http-server", "prod"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 35
    }
  }
  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata = {
    ssh-keys       = "ubuntu:${tls_private_key.ssh_key.public_key_openssh}"
    startup-script = file("${path.module}/scripts/website_setup_script.sh")
  }
}
resource "google_compute_instance" "dev_vms" {
  count        = 2
  name         = "dev-${count.index + 1}"
  machine_type = "e2-small"
  zone         = element(var.dev_zones, count.index)
  tags         = ["http-server", "dev"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 15
    }
  }
  network_interface {
    network = "default"
    access_config {
    }
  }
  metadata = {
    ssh-keys       = "ubuntu:${tls_private_key.ssh_key.public_key_openssh}"
    startup-script = file("${path.module}/scripts/website_setup_script.sh")
  }
}
resource "google_compute_firewall" "ssh" {
  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["monitoring", "prod", "dev"]
}

resource "google_compute_firewall" "node_exporter" {
  name    = "allow-node-exporter"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9100"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["prod", "dev"]
}
resource "google_compute_firewall" "http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}
resource "google_compute_health_check" "http_health_check" {
  name = "http-health-check"

  http_health_check {
    port = 80
  }
}
resource "google_compute_backend_service" "prod_backend" {
  name          = "prod-backend"
  protocol      = "HTTP"
  port_name     = "http"
  timeout_sec   = 10
  health_checks = [google_compute_health_check.http_health_check.id]

  dynamic "backend" {
    for_each = google_compute_instance_group.prod_groups
    content {
      group = backend.value.id
    }
  }
}
resource "google_compute_backend_service" "dev_backend" {
  name          = "dev-backend"
  protocol      = "HTTP"
  port_name     = "http"
  timeout_sec   = 10
  health_checks = [google_compute_health_check.http_health_check.id]

  dynamic "backend" {
    for_each = google_compute_instance_group.dev_groups
    content {
      group = backend.value.id
    }
  }
}
resource "google_compute_instance_group" "prod_groups" {
  count = 2
  name  = "prod-instance-group-${count.index + 1}"
  zone  = element(var.prod_zones, count.index)

  instances = [google_compute_instance.prod_vms[count.index].id]

  named_port {
    name = "http"
    port = 80
  }
}
resource "google_compute_instance_group" "dev_groups" {
  count = 2
  name  = "dev-instance-group-${count.index + 1}"
  zone  = element(var.dev_zones, count.index)

  instances = [google_compute_instance.dev_vms[count.index].id]

  named_port {
    name = "http"
    port = 80
  }
}
resource "google_compute_url_map" "prod_url_map" {
  name            = "prod-load-balancer"
  default_service = google_compute_backend_service.prod_backend.id
}

resource "google_compute_url_map" "dev_url_map" {
  name            = "dev-load-balancer"
  default_service = google_compute_backend_service.dev_backend.id
}

resource "google_compute_target_http_proxy" "prod_http_proxy" {
  name    = "prod-http-proxy"
  url_map = google_compute_url_map.prod_url_map.id
}

resource "google_compute_target_http_proxy" "dev_http_proxy" {
  name    = "dev-http-proxy"
  url_map = google_compute_url_map.dev_url_map.id
}

resource "google_compute_global_address" "prod_lb_ip" {
  name = "prod-lb-ip"
}

resource "google_compute_global_address" "dev_lb_ip" {
  name = "dev-lb-ip"
}

resource "google_compute_global_forwarding_rule" "prod_http_forwarding_rule" {
  name       = "prod-http-forwarding-rule"
  target     = google_compute_target_http_proxy.prod_http_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.prod_lb_ip.address
}

resource "google_compute_global_forwarding_rule" "dev_http_forwarding_rule" {
  name       = "dev-http-forwarding-rule"
  target     = google_compute_target_http_proxy.dev_http_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.dev_lb_ip.address
}