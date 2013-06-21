class PricesUrl

  def initialize(url)
    raise InvalidURL, "You must give an url, ie http://www.ns.nl/api" unless url
    @url = url
  end

  def url (opts = {date: nil})
    opts[:date] ||= Date.today
    "#{@url}?from=Amsterdam&to=Purmerend&date=#{opts[:date].strftime("%d%m%Y")}"
  end

  class InvalidURL < StandardError
  end
end