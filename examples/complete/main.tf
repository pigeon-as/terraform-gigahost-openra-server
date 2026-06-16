terraform {
  required_version = ">= 1.4.0"

  required_providers {
    gigahost = {
      source  = "pigeon-as/gigahost"
      version = "~> 0.5"
    }
  }
}

provider "gigahost" {}

module "openra" {
  source = "../../"

  server = {
    name        = "OpenRA Arena"
    mod         = "ra"
    listen_port = 1234
    password    = "change-me"

    # map hash from the OpenRA resource center (https://resource.openra.net)
    map = "74ea717efc1e1e083d5d84107efeb2c763118293"

    advertise_online       = true
    require_authentication = false
    enable_singleplayer    = false
    enable_vote_kick       = true
    vote_kick_timer        = 30000
  }
}

output "connect_address" {
  value = module.openra.connect_address
}

output "ssh_command" {
  value = module.openra.ssh_command
}

output "ssh_private_key" {
  value     = module.openra.ssh_private_key
  sensitive = true
}
