# Class: nginx::package::debian
#
# This module manages NGINX package installation on debian based systems
#
# Parameters:
#
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# This class file is not called directly
class nginx::package::debian {

  $package_name             = $::nginx::package_name
  $package_source           = $::nginx::package_source
  $package_ensure           = $::nginx::package_ensure
  $package_flavor           = $::nginx::package_flavor
  $passenger_package_ensure = $::nginx::passenger_package_ensure
  $manage_repo              = $::nginx::manage_repo
  $release                  = $::nginx::repo_release

  $distro = downcase($::operatingsystem)

  package { 'nginx':
    ensure => $package_ensure,
    name   => $package_name,
  }

  if $manage_repo {
    include '::apt'
    ensure_packages([ 'apt-transport-https', 'ca-certificates' ])
    Package['apt-transport-https','ca-certificates'] -> Exec['apt_update'] -> Package['nginx']

    case $package_source {
      'nginx', 'nginx-stable': {
        apt::source { 'nginx':
          location => "https://nginx.org/packages/${distro}",
          repos    => 'nginx',
          key      => {'id' => '573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62'},
          release  => $release,
        }
      }
      'nginx-mainline': {
        apt::source { 'nginx':
          location => "https://nginx.org/packages/mainline/${distro}",
          repos    => 'nginx',
          key      => {'id' => '573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62'},
          release  => pick($release, $::lsbdistcodename),
        }
      }
      'passenger': {
        apt::source { 'nginx':
          location => 'https://oss-binaries.phusionpassenger.com/apt/passenger',
          repos    => 'main',
          key      => {'id' => '16378A33A6EF16762922526E561F9B9CAC40B2F7'},
        }

        Package['apt-transport-https','ca-certificates'] -> Apt::Source['nginx']

        package { 'passenger':
          ensure  => $passenger_package_ensure,
          require => Exec['apt_update'],
        }

        if $package_name != 'nginx-extras' {
          warning('You must set $package_name to "nginx-extras" to enable Passenger')
        }
      }
      default: {
        fail("\$package_source must be 'nginx-stable', 'nginx-mainline' or 'passenger'. It was set to '${package_source}'")
      }
    }
  }
}
