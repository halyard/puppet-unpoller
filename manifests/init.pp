# @summary Install unpoller service
#
# @param loki_url sets the URL for the Loki instance
# @param loki_user sets the username for Loki auth
# @param loki_password sets the password for Loki auth
# @param unifi_url sets the URL for the Unifi instance
# @param unifi_user sets the username for Unifi auth
# @param unifi_password sets the password for Unifi auth
# @param ip sets the IP of the unpoller container
# @param prometheus_server_ip sets the IP range to allow for prometheus connections
class unpoller (
  String $loki_url,
  String $loki_user,
  String $loki_password,
  String $unifi_url,
  String $unifi_user,
  String $unifi_password,
  String $ip = '172.17.0.6',
  String $prometheus_server_ip = '0.0.0.0/0',
) {
  file { '/etc/unpoller.conf':
    ensure  => file,
    content => template('unpoller/unpoller.conf.erb'),
  }

  ~> docker::container { 'unpoller':
    image => 'ghcr.io/unpoller/unpoller:latest',
    args  => [
      "--ip ${ip}",
      '-v /etc/unpoller.conf:/etc/unpoller/up.conf',
    ],
    cmd   => '',
  }

  firewall { '100 dnat for prometheus unpoller metrics':
    chain  => 'DOCKER_EXPOSE',
    jump   => 'DNAT',
    proto  => 'tcp',
    source => $prometheus_server_ip,
    dport  => 9130,
    todest => "${ip}:9130",
    table  => 'nat',
  }
}
