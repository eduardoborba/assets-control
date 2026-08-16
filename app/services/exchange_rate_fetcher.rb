require "net/http"
require "json"

class ExchangeRateFetcher
  BASE_URL = "https://api.frankfurter.dev/v1"
  DEFAULT_RATE = 52_000
  RATE_SCALE = ExchangeRate::RATE_SCALE

  def initialize(date:, base_currency: "USD", quote_currency: "BRL")
    @date = date
    @base_currency = base_currency
    @quote_currency = quote_currency
  end

  def call
    cached = ExchangeRate.find_rate(base: @base_currency, quote: @quote_currency, on_date: @date)
    return cached.rate if cached

    rate = fetch_rate
    return fallback_rate unless rate

    ExchangeRate.create!(
      base_currency: @base_currency,
      quote_currency: @quote_currency,
      rate: rate,
      fetched_on: @date
    )

    rate
  end

  private

  def fallback_rate
    latest = ExchangeRate.for_pair(@base_currency, @quote_currency)
                         .where("fetched_on < ?", @date)
                         .latest_first
                         .first
    latest&.rate || DEFAULT_RATE
  end

  def fetch_rate
    uri = URI("#{BASE_URL}/#{@date}?from=#{@base_currency}&to=#{@quote_currency}")
    response = Net::HTTP.get_response(uri)

    return nil unless response.is_a?(Net::HTTPSuccess)

    float_rate = JSON.parse(response.body).dig("rates", @quote_currency)
    (float_rate * RATE_SCALE).round if float_rate
  rescue JSON::ParserError, StandardError => e
    Rails.logger.warn("ExchangeRateFetcher: failed to fetch rate for #{@date}: #{e.message}")
    nil
  end
end
