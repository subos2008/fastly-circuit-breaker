resource "fastly_service_v1" "myservice" {
  name = "sli ${var.environment} cache"

  # NB: SLI also sets the `expires` header
  default_ttl = 0 // We aren't caching, we are providing failover

  domain {
    name = var.cache_host
  }

  backend {
    address            = var.origin_host
    name               = "true-origin"
    port               = 443
    override_host      = var.origin_host
    use_ssl            = var.use_ssl_for_connection_to_origin
    ssl_cert_hostname  = var.origin_host
    ssl_check_cert     = false
    shield             = var.shield_node
    first_byte_timeout = var.first_byte_timeout

    # Our VCL at the time of writing expects to see the error codes from the origin
    # healthcheck       = "true-origin-health-check"  # Don't use a healthcheck - we always want to send to the origin
    # If we use a healthcheck we should understand when the route through the VCL will be, 
    # Presumably into `vcl_error` but what will object.status be set to?
    # How can we test this? Did we test this already? 
  }
  # healthcheck {
  #   name   = "true-origin-health-check"
  #   host   = var.origin_host
  #   path   = var.health_check_path
  #   method = "GET"
  # }

  # backend {
  #   address           = "500-service.mydomain.com"
  #   name              = "500-service"
  #   port              = 443
  #   override_host     = "500-service.mydomain.com"
  #   use_ssl           = var.use_ssl_for_connection_to_origin
  #   ssl_cert_hostname = "500-service.mydomain.com"
  #   shield            = var.shield_node
  #   # healthcheck       = "500-service-health-check" # Don't use a healthcheck - we always want to send to the origin
  # }
  # healthcheck {
  #   name   = "500-service-health-check"
  #   host   = "500-service.mydomain.com"
  #   path   = var.health_check_path
  #   method = "GET"
  # }

  # director {
  #   name     = "mydirector"
  #   quorum   = 1
  #   type     = 1 # 1 = random (round robin ish)
  #   backends = ["true-origin"]
  #   # backends = ["500-service"]
  #   # backends = ["500-service", "true-origin"]
  # }

  # s3logging {
  #   name = "S3 logs"
  #   format_version = 2 // V2 logs from vcl_log https://docs.fastly.com/en/guides/custom-log-formats
  #   bucket_name = aws_s3_bucket.fastly_logs.id
  #   s3_access_key = aws_iam_access_key.log_ingestion_sa.id
  #   s3_secret_key = aws_iam_access_key.log_ingestion_sa.secret
  #   period = 60
  # }

  logging_datadog {
    token  = "..."
    name   = "datadog" // This is used as the name of the logging endpoint in the Fastly UI
    region = "US"
    format = replace(file("${path.module}/datadog-logging-format.hcl"), "SERVICE_NAME_STRING", "fastly-sli-failover-${var.environment}")
  }

  vcl {
    name    = "sli_failover_main"
    content = replace(replace(file("${path.module}/sli-failover-main.vcl"), "SERVICE_NAME_STRING", "fastly-sli-${var.environment}"), "TIMEOUT_WHEN_STALE_AVAILALBE", var.first_byte_timeout_when_stale_available)
    main    = true
  }

  force_destroy = true
}

data "aws_route53_zone" "parent" {
  name = var.route53_zone_name
}

resource "aws_route53_record" "public_ns" {
  zone_id = data.aws_route53_zone.parent.zone_id
  name    = var.cache_host
  type    = "CNAME"
  ttl     = "300"
  records = [var.use_ssl_for_cache_frontend ? var.ssl_cname_for_frontend_dns : "nonssl.global.fastly.net."]
}
