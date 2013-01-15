class kratedev::setup {
    include kratedev::lamp

    package { 
        $params::default_packages: ensure => present;
    }

    exec { 
        "a2ensite kratedev.local":
            unless => "test -L ${params::apache2_path}/sites-enabled/kratedev.local",
            notify => Service["apache2"],
            require => [ 
                Package["apache2"], 
                File["${params::apache2_path}/sites-available/kratedev.local"],
                Exec["a2enmod vhost_alias"],
            ];
        "a2dissite 000-default":
            onlyif => "test -L ${params::apache2_path}/sites-enabled/000-default",
            require => [
                Package["apache2"],
                Exec["a2enmod vhost_alias"],
            ],
            notify => Service["apache2"];
        "a2enmod vhost_alias":
            unless => "test -L ${params::apache2_path}/mods-enabled/vhost_alias.load",
            require => Package["apache2"],
            notify => Service["apache2"];
        "a2enmod rewrite":
            unless => "test -L ${params::apache2_path}/mods-enabled/rewrite.load",
            require => Package["apache2"],
            notify => Service["apache2"];
    }

    file {
        "${params::apache2_path}/sites-available/kratedev.local":
            ensure => present,
            source => "/vagrant/files/apache/kratedev.local",
            require => Package["apache2"],
            mode => 644,
            owner => root,
            group => root;
        "${params::apache2_path}/httpd.conf":
            ensure => present,
            source => "/vagrant/files/apache/httpd.conf",
            require => [ 
                Package["apache2"], 
                Package["phpmyadmin"] 
            ],
            mode => 644,
            owner => root,
            group => root;
        "${params::php5_path}/apache2/php.ini":
            ensure => present,
            mode => 644,
            owner => root,
            group => root,
            source => "/vagrant/files/php/php.ini",
            require => Package["php5"];
        "${params::php5_path}/conf.d/xdebug.ini":
            ensure => present,
            mode => 644,
            owner => root,
            group => root,
            source => "/vagrant/files/php/xdebug.ini",
            require => [ 
                Package["php5-xdebug"],
                File["${params::php5_path}/apache2/php.ini"],
            ],
            notify => Service["apache2"];
    } 

    kratedev::mysql::add_db_user {
        $params::db_load_list: 
            dbs => $params::db_master_list,
            db_root_pass => $params::db_root_pass;
    }
}
