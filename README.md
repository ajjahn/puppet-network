# Puppet Network Interface Module

Module for provisioning (Physical) Network Interfaces

Tested on Ubuntu 12.04, patches to support other operating systems, virtual or bridge interfaces are welcome.

## Installation

Clone this repo to your Puppet modules directory

    git clone git://github.com/ajjahn/puppet-network.git network

## Usage

Tweak and add the following to your site manifest:

    node 'server.example.com' {

      network::interface{ 'eth0':
        method => 'dhcp',
      }

      network::interface{ 'eth1':
        address => 192.168.1.1,
        network => "192.168.1.0",
        broadcast => "192.168.1.255",
      }

    }

Look in manifests/interface.pp for more configuration options.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

This module is released under the MIT license:

* [http://www.opensource.org/licenses/MIT](http://www.opensource.org/licenses/MIT)
