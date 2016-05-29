require 'net/http'
require 'json'

class Doxie::Client
  class Error < StandardError; end
  class ClientError < Error; end
  class ServerError < Error; end
  class AuthenticationError < ClientError; end

  attr_accessor :username, :password, :ip

  def initialize options
    @username = options[:username] || ''
    @password = options[:password] || ''
    @ip = options[:ip] || ''
  end

  def hello
    get('/hello.json')
  end

  def hello_extra
    get('/hello_extra.json')
  end

  def restart
    get('/restart.json')
  end

  private

  def get path
    uri = URI("https://#{ip}:8080#{path}")
    message = Net::HTTP::Get.new(uri.request_uri)
    parse(request(uri, message))
  end

  def request(uri, message)
    http = Net::HTTP.new(uri.host, uri.port)
    http.request(message)
  end

  def parse response
    case response
    when Net::HTTPNoContent
      return true
    when Net::HTTPSuccess
      if response['Content-Type'].split(';').first == 'application/json'
        JSON.parse(response.body)
      else
        response.body
      end
    when Net::HTTPUnauthorized
      raise AuthenticationError, "#{response.code} response from #{ip}"
    when Net::HTTPClientError
      raise ClientError, "#{response.code} response from #{ip}"
    when Net::HTTPServerError
      raise ServerError, "#{response.code} response from #{ip}"
    else
      raise Error, "#{response.code} response from #{ip}"
    end
  end
end
