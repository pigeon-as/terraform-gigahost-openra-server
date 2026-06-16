resource "tls_private_key" "main" {
  algorithm = "ED25519"
}

resource "gigahost_ssh_key" "main" {
  key_name = "openra-deploy-${substr(sha256(tls_private_key.main.public_key_openssh), 0, 8)}"
  key_data = tls_private_key.main.public_key_openssh
}

resource "gigahost_server" "main" {
  product_name = var.product_name
  region_name  = var.region_name
  os_name      = var.os_name
  os_dist      = var.os_dist
  srv_name     = var.srv_name
  ssh_keys     = [gigahost_ssh_key.main.key_id]
}

locals {
  install_dir = "/opt/openra"
  run_user    = "openra"

  appimage_asset = {
    ra  = "OpenRA-Red-Alert-x86_64.AppImage"
    cnc = "OpenRA-Tiberian-Dawn-x86_64.AppImage"
    d2k = "OpenRA-Dune-2000-x86_64.AppImage"
  }[var.server.mod]

  engine_dir = "${local.install_dir}/releases/${var.openra_version}/squashfs-root"

  systemd_unit = templatefile("${path.module}/templates/openra-dedicated.service.tftpl", {
    server      = var.server
    engine_dir  = local.engine_dir
    install_dir = local.install_dir
    run_user    = local.run_user
  })

  install_script = templatefile("${path.module}/templates/install.sh.tftpl", {
    openra_version = var.openra_version
    appimage_url   = "https://github.com/OpenRA/OpenRA/releases/download/${var.openra_version}/${local.appimage_asset}"
    install_dir    = local.install_dir
    run_user       = local.run_user
  })
}

resource "terraform_data" "main" {
  triggers_replace = {
    server_id    = gigahost_server.main.srv_id
    unit_hash    = sha1(local.systemd_unit)
    install_hash = sha1(local.install_script)
  }

  connection {
    type        = "ssh"
    host        = gigahost_server.main.srv_primary_ip
    user        = "root"
    private_key = tls_private_key.main.private_key_openssh
    timeout     = "10m"
  }

  provisioner "file" {
    content     = local.systemd_unit
    destination = "/tmp/openra-dedicated.service"
  }

  provisioner "file" {
    content     = local.install_script
    destination = "/tmp/openra-install.sh"
  }

  provisioner "remote-exec" {
    inline = ["sudo bash /tmp/openra-install.sh"]
  }
}
