class kratedev::php {
    package { 
        "php5": ensure => installed;
        ["php5-cli", "php5-xdebug", "libapache2-mod-php5", "php5-curl"]:
            ensure => installed,
            require => Package["php5"];
    }
}
