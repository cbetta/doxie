# Ruby Doxie API library for Doxie Go Wifi

[![Gem Version](https://badge.fury.io/rb/doxie.svg)](https://badge.fury.io/rb/doxie) [![Build Status](https://travis-ci.org/cbetta/doxie.svg?branch=master)](https://travis-ci.org/cbetta/doxie)

A wrapper for the [Doxie Go Wifi](http://getdoxie.com) API. Specification as per the [developer documentation](http://help.getdoxie.com/content/doxiego/05-advanced/03-wifi/04-api/Doxie-API-Developer-Guide.pdf).

## Installation

Either install directly or via bundler.

```rb
gem 'doxie'
gem 'doxie_scanner' # optional if your Doxie is not on a fixed IP
```

## Usage

### Finding your Doxie

This requires the [`doxie_scanner`](https://github.com/cbetta/doxie_scanner) gem. This gem has a bigger dependency than the `doxie` gem which is why it has been split into a seperate library.

```rb
require 'doxie_scanner'
DoxieScanner.ips
=> [
    [0] "192.168.1.2"
]
```

### Client

The client accepts an `ip` and `password`. You can omit the `password` if your Doxie has non set.

```rb
require 'doxie'
client = Doxie::Client.new(ip: '192.168.1.2', password: 'test')
```

### GET /hello.json

Returns status information for the scanner, firmware, network mode, and password
configuration. Accessing this command does not require a password if one has been
set. The values returned depend on whether the scanner is creating its own
network or joining an existing network.

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

* __model__: Always DX250.
* __name__: The name of the scanner, which defaults to the form "Doxie_XXXXXX".
  The name of a scanner can be changed by using the Doxie desktop app.
* __firmwareWiFi__: The Wi-Fi firmware version.
* __hasPassword__: Indicates whether a password has been set to authenticate API
  access. Passwords can be set and removed by using the Doxie desktop app.
* __MAC__: The MAC address of the scanner as shown on the scanner's bottom
  label.
* __mode__: "AP" if the scanner is creating its own network or "Client" if the
  scanner is joining an existing network.
* __network__: If the scanner is in "Client" mode, this is the name of the
  network it has joined.
* __ip__: If the scanner is in "Client" mode, this is the IP of the scanner on
  the network it has joined.

### GET /hello_extra.json

Returns additional status values. These values are accessed separately from
those in `/hello.json` because there can be a delay of several seconds in
loading them. Accessing this command does not require a password if one has
been set.

```rb
client.hello_extra
=> {
                    "firmware" => "0.26",
    "connectedToExternalPower" => true
}
```

* __firmware__: The scanner firmware version.
* __connectedToExternalPower__: Indicates whether the scanner is connected to
  its AC adapter versus running on battery power. This value is not cached, so
  it immediately reflects any state changes.

### GET /restart.json

Restarts the scanner's Wi-Fi system. The scanner's status light blinks blue
during the restart.

```rb
client.restart
=> true
```

### GET /scans.json

Returns an array of all scans currently in the scanner’s memory. After scanning
a document, the scan will available via the API several second later.

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

Calling this function immediately after scanning something may return a blank
result, even if there are other scans on the scanner, due to the scanner's
memory being in use. Consider retrying if a successful HTTP status code is
returned along with a blank body.

### GET /scans/recent.json

Returns the path to the last scan if available. Monitoring this value for
changes provides a simple way to detect new scans without having to fetch the
entire list of scans.

```rb
client.recent_scans
=> {
    "path" => "/DOXIE/JPEG/IMG_0001.JPG"
}
```

### GET /scans/DOXIE/JPEG/IMG_XXXX.JPG

There are 2 ways to get a scan off your Doxie. The first is to get the raw binary content and then do something with it yourself.

```rb
client.scan "/DOXIE/JPEG/IMG_0001.JPG"
=> "...?]?1:Xt?????'A??}:<??13???z*???}?rT???????z!ESj?/?..."
```

The other is to pass in a filename:

```rb
client.scan "/DOXIE/JPEG/IMG_0001.JPG", 'test.jpg'
=> true
```

### GET /thumbnails/DOXIE/JPEG/IMG_XXXX.JPG

There are 2 ways to get a thumbnail off your Doxie. The first is to get the raw binary content and then do something with it yourself.

```rb
client.thumbnail "/DOXIE/JPEG/IMG_0001.JPG"
=> "...?]?1:Xt?????'A??}:<??13???z*???}?rT???????z!ESj?/?..."
```

The other is to pass in a filename:

```rb
client.thumbnail "/DOXIE/JPEG/IMG_0001.JPG", 'test.jpg'
=> true
```

Thumbnails are constrained to fit within 240x240 pixels. Thumbnails for new
scans are not generated until after the scan has been made available in
`/scans.json` and `/scans/recent.json`. This function will return 404 Not Found
if the thumbnail has not yet been generated. Retrying after a delay is
recommended to handle such cases.

### DELETE /scans/DOXIE/JPEG/IMG_XXXX.JPG

Deletes the scan at the specified path.

```rb
client.delete_scan "/DOXIE/JPEG/IMG_0001.JPG"
=> true
```

Deleting takes several seconds because a lock on the internal storage must be
obtained and released. Deleting may fail if the lock cannot be obtained
(e.g., the scanner is busy), so consider retrying on failure conditions. When
deleting multiple scans, use `/scans/delete.json` for best performance.

### POST /scans/delete.json

Deletes multiple scans in a single operation. This is much faster than deleting
each scan individually.

```rb
client.delete_scans ["/DOXIE/JPEG/IMG_0001.JPG", "/DOXIE/JPEG/IMG_0002.JPG"]
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
