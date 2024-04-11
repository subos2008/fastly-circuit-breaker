{
  "ddsource": "fastly",
  "service_id": "%{req.service_id}V",
  "service": "SERVICE_NAME_STRING",
  "date": "%{begin:%Y-%m-%dT%H:%M:%S%Z}t",
  "time_start": "%{begin:%Y-%m-%dT%H:%M:%S%Z}t",
  "time_end": "%{end:%Y-%m-%dT%H:%M:%S%Z}t",
  "origin": {
    "host": "%v"
  },
  "failover": {
    "missing_stale": "%{X-Missing-Stale-On-Origin-Error}o"
  },
  "http": {
    "request_time_ms": %D,
    "method": "%m",
    "url": "%{json.escape(req.url)}V",
    "useragent": "%{User-Agent}i",
    "referer": "%{Referer}i",
    "request_x_forwarded_for": "%{X-Forwarded-For}i",
    "status_code": "%s"
  },
  "query_string": "%q",
  "network": {
    "client": {
      "ip": "%h"
    },
    "destination": {
      "ip": "%A"
    },
  "bytes_written": %B,
  "bytes_read": %{req.body_bytes_read}V
  },
  "host": "%{Fastly-Orig-Host}i",
  "vcl_error": "%{X-VCL-Error}o",
  "is_tls": %{if(req.is_ssl, "true", "false")}V,
  "request_forwarded": "%{Forwarded}i",
  "request_via": "%{Via}i",
  "request_cache_control": "%{Cache-Control}i",
  "request_x_requested_with": "%{X-Requested-With}i",
  "content_type": "%{Content-Type}o",
  "fastly_info": {
    "state": "%{fastly_info.state}V",
    "error": "%{fastly.error}V",
    "stale_exists": "%{stale.exists}V",
    "server_identity": "%{server.identity}V",
    "server_hostname": "%{server.hostname}V",
    "stale": "%{resp.stale}V",
    "stale_is_revalidating": "%{resp.stale.is_revalidating}V",
    "stale_is_error": "%{resp.stale.is_error}V",
    "visits_this_service": "%{fastly.ff.visits_this_service}V"
  },
  "response_age": "%{Age}o",
  "response_cache_control": "%{Cache-Control}o",
  "response_expires": "%{Expires}o",
  "response_last_modified": "%{Last-Modified}o"
}
