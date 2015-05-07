class PricesUrl

  def initialize(url)
    raise InvalidURL, "You must give an url, ie http://www.ns.nl/api" unless url
    @url = url
  end

  def url (opts = {date: nil, from: "", to: ""})
    opts[:date] = opts[:date].strftime("%d%m%Y") if opts[:date]
    uri = URI.escape(opts.collect{|k,v| "#{k}=#{v}"}.join('&'))
    "#{@url}?#{uri}"
  end

  class InvalidURL < StandardError
  end
end
