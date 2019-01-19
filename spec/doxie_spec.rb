require 'minitest/autorun'
require 'webmock/minitest'
require 'fakefs'
require 'doxie'

describe 'Doxie::Client' do
  def json_response_body(content)
    {
      headers: {
        'Content-Type' => 'application/json;charset=utf-8'
      },
      body: content
    }
  end

  before do
    @json_response_object = { 'key' => 'value' }
    @json_response_body = json_response_body('{"key":"value"}')
    @ip = '192.168.1.1'
    @base_url = "http://#{@ip}:8080"
    @base_url_v2 = "http://#{@ip}:80"
    @client = Doxie::Client.new(ip: @ip)
  end

  describe 'Doxie Models' do
    it 'should assign the right values to each model' do
      assert_equal Doxie::GO, Doxie::API_V1
      assert_equal Doxie::DX250, Doxie::API_V1

      assert_equal Doxie::Q, Doxie::API_V2
      assert_equal Doxie::GO_SE, Doxie::API_V2
      assert_equal Doxie::DX255, Doxie::API_V2
      assert_equal Doxie::DX300, Doxie::API_V2
    end
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

    it 'should error for API V2 models, as the method does not exist' do
      @client = Doxie::Client.new(ip: @ip, model: Doxie::API_V2)
      error = -> { @client.hello_extra }.must_raise(Doxie::Client::Error)
      error.message.must_match "Method does not exist for this model"
    end
  end

  describe 'get /restart.json' do
    it 'should return the result' do
      stub_request(:get, "#{@base_url}/restart.json")
        .to_return(status: 204)
      @client.restart.must_equal(true)
    end
  end

  describe 'get /scans.json' do
    it 'should return the result' do
      stub_request(:get, "#{@base_url}/scans.json")
        .to_return(@json_response_body)
      @client.scans.must_equal(@json_response_object)
    end

    it 'should return an empty array when there are no scans on a V2 model' do
      @client = Doxie::Client.new(ip: @ip, model: Doxie::API_V2)
      stub_request(:get, "#{@base_url_v2}/scans.json")
        .to_return(status: 404)
      @client.scans.must_equal([])
    end
  end

  describe 'get /scans/recent.json' do
    it 'should return the result' do
      stub_request(:get, "#{@base_url}/scans/recent.json")
        .to_return(@json_response_body)
      @client.recent_scans.must_equal(@json_response_object)
    end

    it 'should return an empty array when there are no scans on a V2 model' do
      @client = Doxie::Client.new(ip: @ip, model: Doxie::API_V2)
      stub_request(:get, "#{@base_url_v2}/scans/recent.json")
        .to_return(status: 204)
      @client.recent_scans.must_equal([])
    end
  end

  describe 'get /scans/DOXIE/JPEG/IMG_0001.JPG' do
    it 'should return the result' do
      stub_request(:get, "#{@base_url}/scans/DOXIE/JPEG/IMG_0001.JPG")
        .to_return(@json_response_body)
      @client.scan('/DOXIE/JPEG/IMG_0001.JPG').must_equal(@json_response_object)
    end

    it 'should write to file' do
      stub_request(:get, "#{@base_url}/scans/DOXIE/JPEG/IMG_0001.JPG")
        .to_return(@json_response_body)
      @client.scan('/DOXIE/JPEG/IMG_0001.JPG', 'test.jpg').must_equal(true)
    end
  end

  describe 'get /thumbnails/DOXIE/JPEG/IMG_0001.JPG' do
    it 'should return the result' do
      stub_request(:get, "#{@base_url}/thumbnails/DOXIE/JPEG/IMG_0001.JPG")
        .to_return(@json_response_body)
      @client.thumbnail('/DOXIE/JPEG/IMG_0001.JPG')
             .must_equal(@json_response_object)
    end

    it 'should write to file' do
      stub_request(:get, "#{@base_url}/thumbnails/DOXIE/JPEG/IMG_0001.JPG")
        .to_return(@json_response_body)
      @client.thumbnail('/DOXIE/JPEG/IMG_0001.JPG', 'test.jpg').must_equal(true)
    end
  end

  describe 'DELETE /scans/DOXIE/JPEG/IMG_0001.JPG' do
    it 'should return the result' do
      stub_request(:delete, "#{@base_url}/scans/DOXIE/JPEG/IMG_0001.JPG")
        .to_return(@json_response_body)
      @client.delete_scan('/DOXIE/JPEG/IMG_0001.JPG')
             .must_equal(@json_response_object)
    end
  end

  describe 'POST /scans/delete.json' do
    it 'should return the result' do
      stub_request(:post, "#{@base_url}/scans/delete.json")
        .to_return(status: 204)
      @client.delete_scans(['/DOXIE/JPEG/IMG_0001.JPG'])
             .must_equal(true)
    end
  end

  it 'raises an authentication error exception if the response code is 401' do
    stub_request(:get, "#{@base_url}/hello.json")
      .to_return(status: 401)
    proc { @client.hello }.must_raise(Doxie::Client::Error)
  end

  it 'raises a client error exception if the response code is 4xx' do
    stub_request(:get, "#{@base_url}/hello.json")
      .to_return(status: 400)
    proc { @client.hello }.must_raise(Doxie::Client::Error)
  end

  it 'raises a server error exception if the response code is 5xx' do
    stub_request(:get, "#{@base_url}/hello.json")
      .to_return(status: 500)
    proc { @client.hello }.must_raise(Doxie::Client::Error)
  end
end
