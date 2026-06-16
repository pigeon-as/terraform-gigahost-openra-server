variable "product_name" {
  description = "Gigahost plan; bundles vCPU, RAM and disk."
  type        = string
  default     = "KVM Performance VPS 4GB"
}

variable "region_name" {
  description = "Gigahost region."
  type        = string
  default     = "Sandefjord"
}

variable "os_name" {
  description = "Operating system name, as listed by the gigahost_os data source."
  type        = string
  default     = "Ubuntu 24.04 LTS"
}

variable "os_dist" {
  description = "Operating system distribution codename; an alternative to os_name."
  type        = string
  default     = null
}

variable "srv_name" {
  description = "Server label shown in the Gigahost panel."
  type        = string
  default     = "openra-server"
}

variable "openra_version" {
  description = "OpenRA release tag to install."
  type        = string
  default     = "release-20250330"
}

variable "server" {
  description = "OpenRA dedicated-server settings; keys mirror OpenRA's Server.* settings."
  type = object({
    name                      = optional(string, "Dedicated Server")
    mod                       = optional(string, "ra")
    map                       = optional(string, "")
    listen_port               = optional(number, 1234)
    advertise_online          = optional(bool, true)
    password                  = optional(string, "")
    require_authentication    = optional(bool, false)
    enable_singleplayer       = optional(bool, false)
    record_replays            = optional(bool, false)
    enable_sync_reports       = optional(bool, false)
    enable_geoip              = optional(bool, true)
    enable_lint_checks        = optional(bool, true)
    share_anonymized_ips      = optional(bool, true)
    query_map_repository      = optional(bool, true)
    map_pool                  = optional(list(string), [])
    ban                       = optional(list(string), [])
    profile_id_blacklist      = optional(list(string), [])
    profile_id_whitelist      = optional(list(string), [])
    enable_vote_kick          = optional(bool, true)
    vote_kick_timer           = optional(number, 30000)
    flood_limit_join_cooldown = optional(number, 5000)
  })
  default = {}

  validation {
    condition     = contains(["ra", "cnc", "d2k"], var.server.mod)
    error_message = "server.mod must be one of: ra, cnc, d2k."
  }

  validation {
    condition     = var.server.listen_port >= 1 && var.server.listen_port <= 65535
    error_message = "server.listen_port must be between 1 and 65535."
  }
}
