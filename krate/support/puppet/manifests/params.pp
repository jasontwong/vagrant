class params {
    $php5_path = "/etc/php5"
    $apache2_path = "/etc/apache2"
    $db_root_pass = "password"
    $default_packages = [
        "git", "vim", "htop", "curl",
    ]
    $enabled_modules = ["vhost_alias", "rewrite"]
    $disabled_modules = []
    $enabled_sites = ["kratedev.local"]
    $disabled_sites = ["000-default"]
    $db_load_list = ["aea", "aether_wp"]
    $db_master_list = { 
        "db" => { "password" => "dbpass", "user" => "dbuser", "sql" => "db.sql.example" },
    }
}
