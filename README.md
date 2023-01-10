# Reverse proxy demo

Proof of concept reverse proxy configuration for proxying CMS classic and polaris for sharing cookie data

Terraform config that runs a nginx in an azure app service to proxy traffic

- `/` - proxies `$UPSTREAM_HOST` (`github.com`)
- `/api` - proxies `$API_ENDPOINT` (`api.github.com`)
- `/polaris` - `302` redirects to `https://${API_ENDPOINT}/init?cookie=${cookie}&referer=${referer}&q=${q}` where:
  - `${cookie}` is a [percent encoded](https://en.wikipedia.org/wiki/Percent-encoding) version of the [HTTP cookie header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cookie)
  - `${referer}` is a [percent encoded](https://en.wikipedia.org/wiki/Percent-encoding) version of the [HTTP referer header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referer)
  - `${q}` is a direct reflection of the `?q=` if any parameters passed to `/polaris`