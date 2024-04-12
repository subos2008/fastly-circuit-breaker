# Fastly/Varnish VCL for API Failover

This repository provides a collection of Varnish Configuration Language (VCL) files designed to enable API failover functionality on Fastly's edge network. VCL allows us to override the default behaviour of Fastly's CDN. In this case we detect slow responses and immediately failover instead of waiting for connection timeouts.

This is a technique I used to mitigate some of the issues a client was having during Black Friday where one of the 3rd party endpoints they were using would often slow down under load and cause outages on their site.

It implements failover logic, detecting slow origin responses and serving cached data when necessary.

Terraform files are included to provide this as a terraform module you can drop in to your code.

# Notes

1. vcl_hash - we implement a custom hash. You might need to tweak this to filter out query params you don't want included in the cache's hash.
2. shield nodes make this an interesting bit of code check out [TESTING.md](./TESTING.md) for test cases that illustrate the kind of interesting edge cases that appear based on whether data is being accessed from the shield node's geographic location or not.
3. Fastly is best controlled either via VCL or via its UI. See the code for hints where to avoid setting things in the UI because the VCL manages them.

# Consulting

I consult/contract and enjoy this kind of work. If you have a problem to look at feel free to connect at https://www.linkedin.com/in/ryancocks
