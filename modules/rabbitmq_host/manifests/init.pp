class rabbitmq_host (
  $cluster_nodes = ['rabbit@demomq1', 'rabbit@demomq2', 'rabbit@demomq3'],
  $version = 'latest',
  $confdir = '/etc/rabbitmq',
  $rabbitmq_user = 'rabbitmq',
) {

  $rabbit_host = "rabbit@${::hostname}"

  class{"rabbitmq_host::packages":
    version => "$version",
  }

  Class["${module_name}::packages"]->Class["${module_name}"]

  file { "${confdir}/rabbitmq.config":
    content => template("${module_name}/rabbitmq.config.erb"),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    notify  => Service['rabbitmq-server'],
  }

  file {"${confdir}/enabled_plugins":
    content =>'[rabbitmq_management].',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    notify  => Service['rabbitmq-server'],
  }

  service { 'rabbitmq-server':
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
  }

  rabbitmq_vhost { ['/','test_p']:
    ensure      => 'present',
    require     => Service['rabbitmq-server'],
  }

  rabbitmq_user { 'logger':
    ensure      => 'present',
    taggs       => ['arbitrary_tag1', 'arbitrary_tag2',],
    password    => 'Gh&(j05bFgh!4$%',
    require     => Service['rabbitmq-server'],
  }

  resources{'rabbitmq_vhost':
    purge   => true,
    require => Service['rabbitmq-server'],
  }
}
