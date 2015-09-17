class dummy {

  custom_type{'resource0_to_create':
    property_string1 => 'value_in_manifest',
    property_string2 => 'another_value_in_manifest',
    property_array1 => ['Haskell', 'Erlang'],
    notify => Custom_type['resource1_orderly','resource2_to_modify']
  }

  custom_type{'resource1_orderly':
    property_string1 => 'initial_value',
    property_string2 => 'initial_value',
    property_array1 => ['Ruby', 'pErl', 'PYTHON'],
  }

  custom_type{'resource2_to_modify':
    property_string1 => 'puppet_set_value',
    property_string2 => 'initial_value',
    #property_array1 => ['Ruby', 'pErl', 'java', 'PYTHON'],
  }

  resources{'custom_type':
    purge => true,
  }

}