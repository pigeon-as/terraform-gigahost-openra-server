terraform {
  required_version = ">= 1.4.0"

  required_providers {
    gigahost = {
      source  = "pigeon-as/gigahost"
      version = "~> 0.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
