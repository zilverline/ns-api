class PricesUrl

  def initialize(url)
    raise InvalidURL, "You must give an url, ie http://www.ns.nl/api" unless url
    @url = url
  end

  def url (opts = {date: nil, from: ""})
    opts[:date] ||= Date.today
    url = "#{@url}?from=#{opts[:from]}&to=#{opts[:to]}&date=#{opts[:date].strftime("%d%m%Y")}"
    url += "&via=#{opts[:via]}" if opts[:via]
    url
  end

  class InvalidURL < StandardError
  end
end