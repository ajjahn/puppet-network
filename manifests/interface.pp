define network::interface ( $address = false,
                            $netmask = '255.255.255.0',
                            $up = true,
                            $ensure = present,
                            $onboot = true,
                            $family = 'inet',
                            $method = 'static',
                            $hwaddress = false,
                            $network = false,
                            $gateway = false,
                            $broadcast = false,
                            $reconfig = false ) {


  $device = $name
	# Device string for augeas
  $cur_device = "iface[. = '${device}']"

  if $ensure == 'present' {
  	if $onboot {
  		augeas { "auto-${device}":
  			context => '/files/etc/network/interfaces',
  			changes => "set auto[child::1 = '${device}']/1 ${device}",
  		}
  	}

  	augeas { "common-${device}":
  		context => '/files/etc/network/interfaces',
  		changes => [
  			"set ${cur_device} ${device}",
  			"set ${cur_device}/family ${family}",
  			"set ${cur_device}/method ${method}",
  		],
  		require => $onboot ? {
  			true => Augeas["auto-${device}"],
  		},
  	}

  	case $method {
  		'static': {
  			augeas { "address-${device}":
  				context => '/files/etc/network/interfaces',
  				changes => [
  					"set ${cur_device}/address ${address}",
  					"set ${cur_device}/netmask ${netmask}",
  				],
  				require => Augeas["common-${device}"],
  			}
  		}
  	}

  	if $hwaddress {
  		augeas { "hwaddress-${device}":
  			context => '/files/etc/network/interfaces',
  			changes => $hwaddress ? {
  			  false => "",
  			  absent => "rm ${cur_device}/hwaddress",
  			  default => "set ${cur_device}/hwaddress ${hwaddress}"
  			},
  			require => Augeas["common-${device}"],
  		}
  	}

  	if $network {
  		augeas { "network-${device}":
  			context => '/files/etc/network/interfaces',
  			changes => $network ? {
  			  false => "",
  			  absent => "rm ${cur_device}/network",
  			  default => "set ${cur_device}/network ${network}"
  			},
  			require => Augeas["common-${device}"],
  		}
  	}

		augeas { "broadcast-${device}":
			context => '/files/etc/network/interfaces',
			changes => $broadcast ? {
			  false => "",
			  absent => "rm ${cur_device}/broadcast",
			  default => "set ${cur_device}/broadcast ${broadcast}"
			},
			require => Augeas["common-${device}"],
		}

  	if $gateway {
  		augeas { "gateway-${device}":
  			context => '/files/etc/network/interfaces',
  			changes => $gateway ? {
  			  false => "",
  			  absent => "rm ${cur_device}/gateway",
  			  default => "set ${cur_device}/gateway ${gateway}"
  			},
  			require => Augeas["common-${device}"],
  		}
  	}

  	if $reconfig {
  		exec { "ifdown-${device}":
  			command => "/sbin/ifdown ${device}",
  			onlyif => "/sbin/ifconfig | grep ${device}",
  		}
  		exec { "ifup-${device}":
  			command => "/sbin/ifup ${device}",
  			require => Augeas["common-${device}"],
  		}
  	}
  	else {
  		if $up {
  			exec { "ifup-${device}":
  				command => "/sbin/ifup ${device}",
  				unless  => "/sbin/ifconfig | grep ${device}",
  				require => Augeas["common-${device}"],
  			}
  		} else {
  			exec { "ifdown-${device}":
  				command => "/sbin/ifdown ${device}",
  				onlyif => "/sbin/ifconfig | grep ${device}",
  			}
  		}
  	}
  } else {
  	exec { "ifdown-${device}":
  		command => "/sbin/ifdown ${device}",
  		onlyif => "/sbin/ifconfig | grep ${device}",
  	}

  	augeas { "remove-${device}":
  		context => '/files/etc/network/interfaces',
  		changes => [
  			"rm ${cur_device}",
  			"rm auto[child::1 = '${device}']",
  		],
  		require => Exec["ifdown-${device}"],
  	}
  }
}
