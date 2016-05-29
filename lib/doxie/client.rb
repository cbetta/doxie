require 'net/http'
require 'json'

class Doxie::Client
  class Error < StandardError; end
  class ClientError < Error; end
  class ServerError < Error; end
  class AuthenticationError < ClientError; end

  USERNAME = 'doxie'.freeze

  attr_accessor :ip, :password

  def initialize options
    @ip = options[:ip] || ''
    @password = options[:password] || ''
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

  def scans
    get('/scans.json')
  end

  def recent_scans
    get('/scans/recent.json')
  end


  private

  def get path
    uri = URI("https://#{ip}:8080#{path}")
    message = Net::HTTP::Get.new(uri.request_uri)
    parse(request(uri, message))
  end

  def request(uri, message)
    message.basic_auth USERNAME, password if password
    http = Net::HTTP.new(uri.host, uri.port)
    http.request(message)
  end

  def parse response
    case response
    when Net::HTTPNoContent
      return nil
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
