# @summary Install unpoller service
#
# @param loki_url sets the URL for the Loki instance
# @param loki_user sets the username for Loki auth
# @param loki_password sets the password for Loki auth
# @param unifi_url sets the URL for the Unifi instance
# @param unifi_user sets the username for Unifi auth
# @param unifi_password sets the password for Unifi auth
class unpoller (
  String $loki_url,
  String $loki_user,
  String $loki_password,
  String $unifi_url,
  String $unifi_user,
  String $unifi_password,
) {
  file { '/etc/unpoller.conf':
    ensure  => file,
    content => template('unpoller/unpoller.conf.erb'),
  }

  ~> docker::container { 'unpoller':
    image => 'ghcr.io/unpoller/unpoller:latest',
    args  => [
      '-v /etc/unpoller.conf:/etc/unpoller/up.conf',
    ],
    cmd   => '',
  }

  firewall { '100 allow prometheus unpoller metrics':
    source => $prometheus::server_ip,
    dport  => 9130,
    proto  => 'tcp',
    action => 'accept',
  }
}
