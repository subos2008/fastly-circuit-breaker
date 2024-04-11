import querystring;

sub vcl_recv {
#FASTLY recv

  unset req.http.cookie;
  unset req.http.cache-control;

  # Sort query params (improve cache hit rate)
  set req.url = querystring.sort(req.url);
}

sub vcl_fetch {
#FASTLY fetch

  log {"syslog "} req.service_id {" datadog :: "} {" {   "source": "fastly", "vcl_function": "vcl_fetch", "service": "SERVICE_NAME_STRING-origin-monitor", "is_shield": "} req.backend.is_origin {", "stale_exists": "} stale.exists {", "server_identity": ""} server.identity {"", "server_hostname": ""} server.hostname {"", "http": { "status_code": "} beresp.status {" } } "};

  # Commented out because we are not concerned with this,
  # if everything is working properly then the cache should update from
  # the origin anyways, unless there is an outage in which case we're not
  # concerned about new products going live on site
  # Never cache 404's, fastly would be default
  # if (beresp.status == 404) {
  #   set beresp.cacheable = false;
  # }

  if ((beresp.status >= 500 && beresp.status < 600) || beresp.status == 400) {
    if (stale.exists) {
      return(deliver_stale);
    }
  }

  # The period of time stale content will stay available to serve
  # Note this will conflict with the default inserted by the tick-box in the UI
  # of 12h (as 43200s) so don't enable the tickbox for stale content
  set beresp.stale_if_error = 168h; // 43200s = 12h
  set beresp.stale_while_revalidate = 5m;

  ##############################################################################
  # SLI responses edits:

  # set-cookie header: remove it because caches will not cache responses that 
  #  set cookies
  unset beresp.http.set-cookie;
  # SLI responses have the expires header always, remove it
  # Our desired behaviour is just to store copies of searches
  # so we can reduce the impact by serving stale content when the origin is down.
  unset beresp.http.expires;

  # By default we set a TTL based on the `Cache-Control` header but we don't parse additional directives
  # like `private` and `no-store`.  Private in particular should be respected at the edge:
  if (beresp.http.Cache-Control ~ "(private|no-store)") {
    return(pass);
  }

  return(deliver);
}

sub vcl_error {
#FASTLY error

  log {"syslog "} req.service_id {" datadog :: "} {" {   "source": "fastly", "vcl_function": "vcl_error", "service": "SERVICE_NAME_STRING-origin-monitor", "http": { "status_code": "} obj.status {" } } "};

  if (stale.exists) {
    return(deliver_stale);
  }

  return(deliver);
}

sub vcl_hash {
#FASTLY hash

  # Remove cip from querystring, cip = client IP
  if (req.url ~ "\?") {
      set req.url = querystring.regfilter(req.url, "cip"); # Regexp, Use '|' to separate additional
      set req.url = querystring.sort(req.url);
  }

  # We still want to pass SLIPid to the backend but we don't want to include it in the hash
  declare local var.normalized_url STRING;
  set var.normalized_url = querystring.regfilter(req.url, "SLIPid");

  set req.hash += var.normalized_url;
  set req.hash += req.http.host;
  set req.hash += req.vcl.generation;

  return (hash);
}

sub vcl_miss {
#FASTLY miss

  if (stale.exists) {
    # Also set in vcl_pass
    set bereq.first_byte_timeout = TIMEOUT_WHEN_STALE_AVAILALBE;
  }

  return(fetch);
}

sub vcl_hit {
#FASTLY hit

  return(deliver);
}

sub vcl_pipe {
#FASTLY pipe

}

sub vcl_pass {
#FASTLY pass

  if (stale.exists) {
    # Also set in vcl_miss
    set bereq.first_byte_timeout = TIMEOUT_WHEN_STALE_AVAILALBE;
  }
}
