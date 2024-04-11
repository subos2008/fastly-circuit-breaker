variable "region" {
}

# variable "remote_state_bucket" {}

# variable "remote_state_region" {}

variable "environment" {
  description = "i.e. dev / prd"
}

# Origin
variable "origin_host" {
  description = "host dns name of the origin (don't include http)"
}

variable "first_byte_timeout" {
  type        = number
  default     = 15000
  description = "Fastly default 15000, we see 12s when SLI is struggling"
}

variable "first_byte_timeout_when_stale_available" {
  type        = string
  default     = "2s"
  description = "RTIME form, i.e. 2s. SLI origin is sub 1s when healthy"
}

variable "health_check_path" {
  description = "Path on the origin servers to check is the origin is healthy"
}

variable "cache_host" {
  description = "DNS hostname the cache will serve content on"
}

variable "route53_zone_name" {
  description = "zone name to add the dns entry for the cache frontend"
}

# SSL
variable "use_ssl_for_connection_to_origin" {
  default = true
}

variable "use_ssl_for_cache_frontend" {
  default = true
}

variable "ssl_cname_for_frontend_dns" {
  description = "provided by fastly after certificate configuration"
}

# Shield Node
variable "shield_node" {
  # see https://developer.fastly.com/learning/concepts/shielding/#choosing-a-shield-location
  default = "mdw-il-us"
  type    = string
}
