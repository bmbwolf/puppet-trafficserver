#   Copyright 2015 Brainsware
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# This define assembles remap.config
define trafficserver::remap (
  $ensure           = 'present',
  $type             = 'map',
  $activatefilter   = undef,
  $deactivatefilter = undef,
  $config           = [],
  $order            = 0,
){

  validate_re($ensure, '^(present|absent)$')
  validate_re($type, '^(regex_)?(map|map_with_referer|map_with_recv_port|reverse_map|redirect|redirect_temporary)$')

  if empty($activatefilter) and empty($deactivatefilter) and empty($config) {
    fail("Trafficserver::remap[${title}]: one of activatefilter, deactivatefilter, config must be set!")
  }

  $type_order = $type? {
    # http://trafficserver.readthedocs.org/en/latest/reference/configuration/remap.config.en.html#precedence
    'map_with_recv_port'       => 1000,
    'regex_map_with_recv_port' => 1000,
    'map'                      => 2000,
    'regex_map'                => 2000,
    'reverse_map'              => 2000,
    'map_with_referer'         => 2000,
    'regex_map_with_referer'   => 2000,
    'redirect'                 => 3000,
    'redirect_temporary'       => 3000,
    'regex_redirect'           => 4000,
    'regex_redirect_temporary' => 4000,
    default                    => 2000, # our default is same as map/regex_remap/reverse_map
  }

  # used variables in this template
  # * config
  # * type
  # * activatefilter
  # * deactivatefilter
  concat::fragment { "ensure ${title} ${ensure} in remap.config":
    ensure  => $ensure,
    order   => $type_order + $order,
    target  => $trafficserver::params::remap_config,
    content => template($trafficserver::params::remap_template),
  }

}
