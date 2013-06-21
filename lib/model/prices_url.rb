class PricesUrl

  def initialize(url)
    raise InvalidURL, "You must give an url, ie http://www.ns.nl/api" unless url
    @url = url
    @date = Date.today
  end

  def url
    "#{@url}?from=Amsterdam&to=Purmerend&date=#{@date.strftime("%d%m%Y")}"
  end

  class InvalidURL < StandardError
  end
end