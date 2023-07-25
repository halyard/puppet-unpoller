# @summary Install unpoller service
#
# @param influx_url sets the InfluxDB hostname
# @param influx_org sets the InfluxDB Organization
# @param influx_token sets the credential to use for metric submission
# @param influx_bucket sets the InfluxDB bucket
# @param loki_url sets the URL for the Loki instance
# @param loki_user sets the username for Loki auth
# @param loki_password sets the password for Loki auth
# @param unifi_url sets the URL for the Unifi instance
# @param unifi_user sets the username for Unifi auth
# @param unifi_password sets the password for Unifi auth
class unpoller (
  String $influx_url,
  String $influx_org,
  String $influx_token,
  String $influx_bucket,
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
}
