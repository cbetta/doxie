require 'net/http'
require 'json'

module Doxie
  # The client for connecting to a Doxie scanner.
  #
  # Use the IP and password to connect as follows:
  #   Doxie::Client.new(ip: '192.168.1.2', model: Doxie::Q, password: 'test')
  class Client
    class Error < StandardError; end

    USERNAME = 'doxie'.freeze

    attr_accessor :ip, :password, :model, :port

    def initialize(options)
      @ip = options[:ip] || ''
      @password = options[:password] || ''
      @model = options[:model] || Doxie::API_V1
      @port = @model ==  Doxie::API_V1 ? 8080 : 80
    end

    def hello
      get('/hello.json')
    end

    def hello_extra
      raise Error.new('Method does not exist for this model') if model ==  Doxie::API_V2
      get('/hello_extra.json')
    end

    def restart
      get('/restart.json') || true
    end

    def scans
      get('/scans.json')
    rescue Doxie::Client::Error => error
      # a 404 is thrown on the Doxie Q and 
      # Doxie GO SE when there are no scans
      raise error if model == Doxie::API_V1
      [] 
    end

    def recent_scans
      get('/scans/recent.json') || []
    end

    def scan(scan_name, file_name = nil)
      file "/scans#{scan_name}", file_name
    end

    def thumbnail(scan_name, file_name = nil)
      file "/thumbnails#{scan_name}", file_name
    end

    def delete_scan(scan_name)
      delete("/scans#{scan_name}") || true
    end

    def delete_scans(scan_names)
      post('/scans/delete.json', scan_names) || true
    end

    private

    def get(path)
      uri = uri_for(path)
      message = Net::HTTP::Get.new(uri.request_uri)
      parse(request(uri, message))
    end

    def post(path, params)
      uri = uri_for(path)
      message = Net::HTTP::Post.new(uri.request_uri)
      message.body = JSON.generate(params)
      parse(request(uri, message))
    end

    def delete(path)
      uri = uri_for(path)
      message = Net::HTTP::Delete.new(uri.request_uri)
      parse(request(uri, message))
    end

    def uri_for(path)
      URI("http://#{ip}:#{port}#{path}")
    end

    def request(uri, message)
      message.basic_auth USERNAME, password if password && password.length > 0
      http = Net::HTTP.new(uri.host, uri.port)
      http.request(message)
    end

    def parse(response)
      case response
      when Net::HTTPNoContent
        nil
      when Net::HTTPSuccess
        parse_json(response)
      else
        raise Error, response
      end
    end

    def parse_json(response)
      if response['Content-Type'].split(';').first == 'application/json'
        JSON.parse(response.body)
      else
        response.body
      end
    end

    def file(scan_name, file_name)
      body = get(scan_name)
      if file_name
        File.open(file_name, 'wb') { |file| file.write(body) }
        true
      else
        body
      end
    end
  end
end
