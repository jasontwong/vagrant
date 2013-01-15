class kratedev::apache {
    package { "apache2":
        ensure => present,
    }
    
    service { "apache2":
        ensure => running,
        hasstatus => true,
        hasrestart => true,
        require => Package["apache2"],
        provider => "debian",
    }

    define module ( $ensure = 'present', $apache2_path = '/etc/apache2' ) {
        case $ensure {
            'present' : {
                exec { "a2enmod $name":
                    unless => "readlink -e ${apache2_path}/mods-enabled/${name}.load",
                    notify => Service["apache2"],
                }
            }
            'absent': {
                exec { "a2dismod $name":
                    onlyif => "readlink -e ${apache2_path}/mods-enabled/${name}.load",
                    notify => Service["apache2"],
                }
            }
            default: { err ( "Unknown ensure value: '$ensure'" ) }
        }
    }

    define site ( $ensure = 'present', $apache2_path = '/etc/apache2' ) {
        case $ensure {
            'present' : {
                exec { "a2ensite $name":
                    unless => "readlink -e ${apache2_path}/sites-enabled/$name",
                    notify => Service["apache2"],
                    refreshonly => true,
                }
            }
            'absent' : {
                exec { "a2dissite $name":
                    onlyif => "readlink -e ${apache2_path}/sites-enabled/$name",
                    notify => Service["apache2"],
                    refreshonly => true,
                }
            }
            default: { err ( "Unknown ensure value: '$ensure'" ) }
        }
    }
}

