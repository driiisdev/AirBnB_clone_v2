# using puppet command to deploy static files to the server

node default {

  exec { '/usr/bin/env sudo apt-get -y update':
    path => ['/bin', '/usr/bin'],
  } ->

  exec { '/usr/bin/env sudo service nginx start':
    path => ['/bin', '/usr/bin'],
    require => Exec['/usr/bin/env sudo apt-get -y update'],
  } ->

  exec { '/usr/bin/env sudo mkdir -p /data/web_static/releases/test/':
    path => ['/bin', '/usr/bin'],
    require => Exec['/usr/bin/env sudo service nginx start'],
  } ->

  exec { '/usr/bin/env sudo mkdir -p /data/web_static/shared/':
    path => ['/bin', '/usr/bin'],
    require => Exec['/usr/bin/env sudo mkdir -p /data/web_static/releases/test/'],
  } ->

  exec { '/usr/bin/env echo "This is a test" > /data/web_static/releases/test/index.html':
    path => ['/bin', '/usr/bin'],
    require => Exec['/usr/bin/env sudo mkdir -p /data/web_static/shared/'],
  } ->

  exec { '/usr/bin/env sudo ln -sf /data/web_static/releases/test/ /data/web_static/current':
    path => ['/bin', '/usr/bin'],
    require => Exec['/usr/bin/env echo "This is a test" > /data/web_static/releases/test/index.html'],
  } ->

  exec { '/usr/bin/env sudo sed -i \'38i\\tlocation /hbnb_static/ {\n\t\talias /data/web_static/current/;\n\t}\n\' /etc/nginx/sites-available/default':
    path => ['/bin', '/usr/bin'],
    require => Exec['/usr/bin/env sudo ln -sf /data/web_static/releases/test/ /data/web_static/current'],
  } ->

  exec { '/usr/bin/env sudo service nginx restart':
    path => ['/bin', '/usr/bin'],
    require => Exec['/usr/bin/env sudo sed -i \'38i\\tlocation /hbnb_static/ {\n\t\talias /data/web_static/current/;\n\t}\n\' /etc/nginx/sites-available/default'],
  } ->

  exec { '/usr/bin/env sudo chown -R ubuntu:ubuntu /data/':
    path => ['/bin', '/usr/bin'],
    require => Exec['/usr/bin/env sudo service nginx restart'],
  }

  # Ensure the /data directory exists with the desired owner and permissions

  file { '/data':
    ensure => directory,
    owner  => 'ubuntu',
    group  => 'ubuntu',
    mode   => '0755',
  }

  # Ensure /data/web_static and /data/web_static/releases directories exist with the right permissions
  
  file { '/data/web_static':
    ensure => directory,
    owner  => 'ubuntu',
    group  => 'ubuntu',
    mode   => '0755',
    require => File['/data'],
  }

  file { '/data/web_static/releases':
    ensure => directory,
    owner  => 'ubuntu',
    group  => 'ubuntu',
    mode   => '0755',
    require => File['/data/web_static'],
  }

  file { '/data/web_static/releases/test':
    ensure => directory,
    owner  => 'ubuntu',
    group  => 'ubuntu',
    mode   => '0755',
    require => File['/data/web_static/releases'],
  }

  file { '/data/web_static/releases/test/index.html':
    ensure => file,
    owner  => 'ubuntu',
    group  => 'ubuntu',
    mode   => '0644',
    require => File['/data/web_static/releases/test'],
  }

  $source_path = './versions/web_static_20230921150558.tgz'
  $archive_name = strftime('web_static_%Y%m%d%H%M%S')
  $dest_path = "/data/web_static/releases/${archive_name}"
  $web_static_dir = '/data/web_static/releases/web_static'

  exec { 'Copy web archive to remote server':
    command => "cp ${source_path} /tmp/",
    path    => ['/bin', '/usr/bin'],
    user    => 'ubuntu',
    require => File[$source_path],
  }

  file { $source_path:
    ensure => file,
  }

  exec { 'Extract archive':
    command => "tar xzvf /tmp/web_static_20230921150558.tgz -C /data/web_static/releases/",
    user    => 'ubuntu',
    path    => ['/bin', '/usr/bin'],
    creates => $web_static_dir,
    require => Exec['Copy web archive to remote server'],
  }

  file { $dest_path:
    ensure  => directory,
    require => Exec['Extract archive'],
  }

  exec { 'Rename extracted folder':
    command => "mv /data/web_static/releases/web_static/* /data/web_static/releases/${archive_name}/",
    path    => ['/bin', '/usr/bin'],
    onlyif  => "test -d ${web_static_dir}",
    require => File[$dest_path],
  }

  file { '/data/web_static/current':
    ensure  => link,
    target  => $dest_path,
    require => Exec['Rename extracted folder'],
  }
}
