# Doxie Ruby API Wrapper

A wrapper for the Doxie Go Wifi API. Specification as per the [developer documentation](http://help.getdoxie.com/content/doxiego/05-advanced/03-wifi/04-api/Doxie-API-Developer-Guide.pdf).

## Installation

Either install directly or via bundler.

```rb
gem 'doxie'
```

## Usage

### Client

The client accepts a `username`, `password`, and `ip`. You can omit `username` and `password` if your Doxie has non set.

```rb
require 'doxie'
client = Doxie::Client.new(username: 'john', password: 'test', ip: '192.168.1.2')
```

### GET /hello.json

```rb
client.hello
=> {"model"=>"DX250", "name"=>"Doxie_062300", "firmwareWiFi"=>"1.29", "hasPassword"=>false, "MAC"=>"00:11:11:11:11:00", "mode"=>"Client", "network"=>"YourNetworkName", "ip"=>"192.168.1.2"}
```

### GET /hello_extra.json

```rb
client.hello_extra
=> {"firmware"=>"0.26", "connectedToExternalPower"=>false}
```

### GET /restart.json

```rb
client.restart
=> true
```

## Contributing

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull request** so that we can review your changes

### Development

* `bundle install` to get dependencies
* `rake` to run tests
* `rake console` to run a local console with the library loaded

## Credits and License

Thanks to [@timcraft](https://github.com/timcraft) for the excellent [Nexmo Ruby livrary](https://github.com/Nexmo/nexmo-ruby) which helped me remember how to nicely wrap the Doxie API.

This library is released under the [MIT License](LICENSE).
