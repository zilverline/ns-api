class PricesUrl

  def initialize(url)
    raise InvalidURL, "You must give an url, ie http://www.ns.nl/api" unless url
    @url = url
  end

  def url (opts = {date: nil, from: ""})
    opts[:date] ||= Date.today
    via = opts[:via]
    if via
      "#{@url}?from=#{opts[:from]}&to=#{opts[:to]}&via=#{opts[:via]}&date=#{opts[:date].strftime("%d%m%Y")}"
    else
      "#{@url}?from=#{opts[:from]}&to=#{opts[:to]}&date=#{opts[:date].strftime("%d%m%Y")}"
    end
  end

  class InvalidURL < StandardError
  end
end