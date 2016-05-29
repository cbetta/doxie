# Doxie Ruby API Wrapper

[![Gem Version](https://badge.fury.io/rb/doxie.svg)](https://badge.fury.io/rb/doxie) [![Build Status](https://travis-ci.org/cbetta/doxie.svg?branch=master)](https://travis-ci.org/cbetta/doxie)

A wrapper for the Doxie Go Wifi API. Specification as per the [developer documentation](http://help.getdoxie.com/content/doxiego/05-advanced/03-wifi/04-api/Doxie-API-Developer-Guide.pdf).

## Installation

Either install directly or via bundler.

```rb
gem 'doxie'
```

## Usage

### Client

The client accepts an `ip` and `password`. You can omit the `password` if your Doxie has non set.

```rb
require 'doxie'
client = Doxie::Client.new(ip: '192.168.1.2', password: 'test')
```

### GET /hello.json

```rb
client.hello
=> {
           "model" => "DX250",
            "name" => "Doxie_062300",
    "firmwareWiFi" => "1.29",
     "hasPassword" => true,
             "MAC" => "00:11:11:11:11:00",
            "mode" => "Client",
         "network" => "YourWifi",
              "ip" => "192.168.1.2"
}
```

### GET /hello_extra.json

```rb
client.hello_extra
=> {
                    "firmware" => "0.26",
    "connectedToExternalPower" => true
}
```

### GET /restart.json

```rb
client.restart
=> true
```

### GET /scans.json

```rb
client.scans
=> [
    [0] {
            "name" => "/DOXIE/JPEG/IMG_0001.JPG",
            "size" => 900964,
        "modified" => "2010-05-01 00:02:38"
    }
]
```


### GET /scans/recent.json

```rb
client.recent_scans
=> {
    "path" => "/DOXIE/JPEG/IMG_0001.JPG"
}
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
