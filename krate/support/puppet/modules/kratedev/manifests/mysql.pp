class kratedev::mysql {
    $db_root_pass = $params::db_root_pass

	package { 
        "mysql-server": ensure => installed ;
        "libapache2-mod-auth-mysql": 
            ensure => installed,
            require => Package["apache2"];
	    "php5-mysql":
            ensure => installed,
            require => Package["php5"];
        "phpmyadmin":
            ensure => installed,
            require => [ Package["php5-mysql"], Package["libapache2-mod-auth-mysql"] ];
    }

 	service { "mysql":
 	   ensure => running,
 	   enable => true,
 	   hasrestart => true,
 	   require => Package["mysql-server"],
    }

  	user { "mysql":
  	  ensure => present,
  	  require => Package["mysql-server"],
  	}

    file { "/var/dbs_loaded":
        ensure => directory,
    }

    exec { "set-mysql-root-password":
        unless => "mysqladmin -uroot -p$db_root_pass status",
        command => "mysqladmin -uroot password $db_root_pass",
        require => Service["mysql"],
    }
    
    define add_db_user ( $dbs, $db_root_pass ) {
        $db = $dbs[$name]
        $user = $db["user"]
        $password = $db["password"]
        $db_dir = "/vagrant/files/dbs"
        $sql = $db["sql"]

        exec { 
            "create-$name-db":
                unless => "mysql -u$user -p$password $name",
                command => "mysql -uroot -p$db_root_pass -e \"create database $name; grant all on $name.* to $user@localhost identified by '$password';\"",
                require => [ Exec["set-mysql-root-password"], Package["mysql-server"] ];
            "import-$name-sql":
                onlyif => "test -f $db_dir/$sql",
                command => "mysql -u$user -p$password $name < $db_dir/$sql && touch /var/dbs_loaded/$name",
                creates => "/var/dbs_loaded/$name",
                require => [ Exec["set-mysql-root-password"], File["/var/dbs_loaded"], Package["mysql-server"] ];
        }
    }
}
