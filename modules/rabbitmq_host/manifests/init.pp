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

  rabbitmq_cookie {'abracadabra':
    ensure    => 'present',
    before    => Service['rabbitmq-server'],
    notify    => Service['rabbitmq-server'],
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

  rabbitmq_user { 'producer':
    ensure      => 'present',
    taggs       => ['arbitrary_tag1', 'arbitrary_tag2',],
    password    => 'Gh&(j05bFgh!3$%',
    require     => Service['rabbitmq-server'],
  }

  rabbitmq_user { 'consumer':
    ensure      => 'present',
    taggs       => ['arbitrary_tag1', 'arbitrary_tag2',],
    password    => 'Gh&(j05bFgh!3$%',
    require     => Service['rabbitmq-server'],
  }

  rabbitmq_acl {'producer@test_p':
    configure => '^logex$',
    write     => '^logex$',
    read      => '^$',
    require   => [ Rabbitmq_vhost['test_p'], Rabbitmq_user['producer'], ]
  }

  rabbitmq_acl {'consumer@test_p':
    configure => '^logq$',
    write     => '^logq$',
    read      => '^(logex|logq)$',
    require   => [ Rabbitmq_vhost['test_p'], Rabbitmq_user['consumer'], ]
  }

  rabbitmq_policy{"logpile":
    policy    => '{ "ha-mode":"exactly","ha-params":2 }',
    vhost     => 'test_p',
    apply_to   => 'queues',
    match => '^logq$',
    priority  =>'1',
    require   => Rabbitmq_vhost['test_p'],
  }

  resources{
    [ 'rabbitmq_vhost',
      'rabbitmq_user',
      'rabbitmq_acl',
      'rabbitmq_policy']:
        purge   => true,
        require => Service['rabbitmq-server'],
  }
}
