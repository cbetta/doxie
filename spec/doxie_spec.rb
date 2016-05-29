require 'minitest/autorun'
require 'webmock/minitest'
require "minitest/reporters"
require 'doxie'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

describe 'Doxie::Client' do
  def json_response_body(content)
    {headers: {'Content-Type' => 'application/json;charset=utf-8'}, body: content}
  end

  before do
    @json_response_object = {'key' => 'value'}
    @json_response_body = json_response_body('{"key":"value"}')
    @ip = '192.168.1.1'
    @base_url = "http://#{@ip}:8080"
    @client = Doxie::Client.new(ip: @ip)
  end

  describe 'get /hello.json' do
    it 'should return the result' do
      stub_request(:get, "#{@base_url}/hello.json")
        .to_return(@json_response_body)
      @client.hello.must_equal(@json_response_object)
    end
  end

  describe 'get /hello_extra.json' do
    it 'should return the result' do
      stub_request(:get, "#{@base_url}/hello_extra.json")
        .to_return(@json_response_body)
      @client.hello_extra.must_equal(@json_response_object)
    end
  end

  describe 'get /restart.json' do
    it 'should return the result' do
      stub_request(:get, "#{@base_url}/restart.json")
        .to_return(status: 204)
      @client.restart.must_equal(true)
    end
  end

  it 'raises an authentication error exception if the response code is 401' do
    stub_request(:get, "#{@base_url}/hello.json")
      .to_return(status: 401)
    proc { @client.hello }.must_raise(Doxie::Client::AuthenticationError)
  end

  it 'raises a client error exception if the response code is 4xx' do
    stub_request(:get, "#{@base_url}/hello.json")
      .to_return(status: 400)
    proc { @client.hello }.must_raise(Doxie::Client::ClientError)
  end

  it 'raises a server error exception if the response code is 5xx' do
    stub_request(:get, "#{@base_url}/hello.json")
      .to_return(status: 500)
    proc { @client.hello }.must_raise(Doxie::Client::ServerError)
  end
end
