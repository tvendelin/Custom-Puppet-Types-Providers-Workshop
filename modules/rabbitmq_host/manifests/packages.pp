class rabbitmq_host::packages(
  $version,
) {
  Package {
    ensure => latest,
    subscribe => File['/etc/apt/'],
  }

  File {
    ensure => 'file',
    owner  => 'root',
    mode   => '0644',
  }

  file { '/etc/apt/':
    source => "puppet:///modules/${module_name}/apt",
    recurse=>true,
  }

#  package { [ 'erlang-asn1',
#							'erlang-base',
#							'erlang-corba',
#							'erlang-crypto',
#							'erlang-diameter',
#							'erlang-edoc',
#							'erlang-eldap',
#							'erlang-erl-docgen',
#							'erlang-eunit',
#							'erlang-ic',
#							'erlang-inets',
#							'erlang-mnesia',
#							'erlang-nox',
#							'erlang-odbc',
#							'erlang-os-mon',
#							'erlang-parsetools',
#							'erlang-percept',
#							'erlang-public-key',
#							'erlang-runtime-tools',
#							'erlang-snmp',
#							'erlang-ssh',
#							'erlang-ssl',
#							'erlang-syntax-tools',
#							'erlang-tools',
#							'erlang-webtool',
#							'erlang-xmerl']:
#    before => Package['rabbitmq-server'],
#  }

  package { 'rabbitmq-server':
    ensure=>"${version}" # MUST be same across cluster
  }

}
