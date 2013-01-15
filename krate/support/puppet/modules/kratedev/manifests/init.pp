class kratedev {
    Exec {
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ]
    }

    exec { "apt-get update":; }

    # Ensure apt-get update has been run before installing any packages
    Exec["apt-get update"] -> Package <| |>

    include kratedev::setup
}
