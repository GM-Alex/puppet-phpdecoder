define phpdecoder::install (
  $php_version = '5.3',
  $type        = 'zend',
  $modules_dir = '/etc/apache2/modules/zgl/',
  $php_ini_dir = '/etc/php5/apache2/conf.d/',
) {
  if ! defined(File["${modules_dir}"]) {
      file { "${modules_dir}":
          ensure => 'directory',
          mode   => 750,
          owner  => 'root',
      }
  }

  if $type == 'zend' {
    if versioncmp($php_version, '5.3') < 0 {
      $decoder_type = 'ZendOptimizer'
      $ini_file     = 'zendoptimizer.ini'
    } else {
      $decoder_type = 'ZendGuardLoader'
      $ini_file     = 'zendguardloader.ini'
    }
  } elsif $type == 'ioncube' {
      $decoder_type = 'ioncube'
      $ini_file     = 'ioncubeloader.ini'
  }

  $short_php_version = regsubst($php_version, '^(\d+\.\d+).*$', '\1')

  if ! defined(File["${modules_dir}${decoder_type}-php-${short_php_version}.so"]) {
    file { "${modules_dir}${decoder_type}-php-${short_php_version}.so":
      ensure    => present,
      source    => "puppet:///modules/phpdecoder/${decoder_type}-php-${short_php_version}.so",
      subscribe => File["${modules_dir}"],
      mode      => 755,
  }

  if ! defined(File["${php_ini_dir}${ini_file}"]) {
    file { "${php_ini_dir}${ini_file}":
      ensure    => present,
      content   => template("phpdecoder/${ini_file}.erb"),
      subscribe => File["${modules_dir}${decoder_type}-php-${short_php_version}.so"],
      notify    => Service['httpd'],
    }
  }
}
