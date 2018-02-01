module UrlsHelper
  def full_url(url)
    'http://' + request.host_with_port + '/' + url.short_url
  end
end
