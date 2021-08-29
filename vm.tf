data "google_compute_image" "my-image" {
  family  = "centos-7"
  project = "centos-cloud"
}

# Creates a GCP VM Instance.
resource "google_compute_instance" "vm" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["http-server"]
  labels       = var.labels

  boot_disk {
    initialize_params {
      image = data.google_compute_image.my-image.self_link
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = data.template_file.nginx.rendered
  #metadata_startup_script = "echo hi > /test.txt"
}

data "template_file" "nginx" {
  template = "${file("template/install.sh")}"

  vars = {
    ufw_allow_nginx = "Nginx HTTP"
  }
}
