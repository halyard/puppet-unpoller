# @summary Install unpoller service
#
# @param version sets the unpoller tag to use
class unpoller (
  String $version = 'v2.7.13',
) {
  $arch = $facts['os']['architecture'] ? {
    'x86_64'  => 'amd64',
    'arm64'   => 'armv7',
    'aarch64' => 'armv7',
    'arm'     => 'armv7',
    default   => 'error',
  }

  $binfile = '/usr/local/bin/unpoller'
  $fileversion = regsubst($version, '^v.*$', '\1')
  $filename = "unpoller_${fileversion}_${downcase($facts['kernel'])}_${arch}.tar.gz"
  $url = "https://github.com/akerl/slack-mastodon/releases/download/${version}/${filename}"

  group { 'unpoller':
    ensure => present,
    system => true,
  }

  user { 'unpoller':
    ensure => present,
    system => true,
    gid    => 'unpoller',
    shell  => '/usr/bin/nologin',
    home   => '/var/lib/unpoller',
  }

  exec { 'download unpoller':
    command => "/usr/bin/curl -sLo '${binfile}' '${url}' && chmod a+x '${binfile}'",
    unless  => "/usr/bin/test -f ${binfile} && ${binfile} version | grep '${version}'",
  }

  file { [
      '/var/lib/unpoller',
      '/var/lib/unpoller/.config',
      '/var/lib/unpoller/.config/slack-mastodon',
    ]:
      ensure => directory,
      owner  => 'unpoller',
      group  => 'unpoller',
      mode   => '0750',
  }

  file { '/var/lib/unpoller/.config/slack-mastodon/config.yml':
    ensure  => file,
    mode    => '0640',
    owner   => 'unpoller',
    group   => 'unpoller',
    content => template('unpoller/config.yml.erb'),
  }

  file { '/etc/systemd/system/slack-mastodon.service':
    ensure => file,
    source => 'puppet:///modules/unpoller/slack-mastodon.service',
  }

  file { '/etc/systemd/system/slack-mastodon.timer':
    ensure  => file,
    content => template('unpoller/slack-mastodon.timer.erb'),
  }

  ~> service { 'slack-mastodon.timer':
    ensure  => running,
    enable  => true,
    require => File['/var/lib/unpoller/.config/slack-mastodon/config.yml'],
  }
}
