class base::services {
    
    # Here is where we would disable any services by default
    # Disable cups by default.  It breaks things like iptables and who prints on a UAV?!
    service { ["cups", "cups-browsed"]:
        ensure      => stopped,
        enable      => false
    } ->
    package { ["cups", "cups-filters", "cups-filters-core-drivers", "printer-driver-*", "cups-daemon"]:
        ensure      => purged,
    }
    # Stop postfix, we don't need a mail service/relay for now
    service { "postfix":
        ensure      => stopped,
        enable      => false,
    }


    # Here is where we would enable any services by default
    # service { "example":
    #   ensure      => running,
    #   enable      => true
    # }

}