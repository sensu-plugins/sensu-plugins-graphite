#! /usr/bin/env ruby
#
#   check-graphite-hosts
#
# DESCRIPTION:
#   This plugin checks the number of hosts within Graphite that are sending
#   data, and alerts if it is below a given threshold
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   #YELLOW
#
# NOTES:
#
# LICENSE:
#   Copyright 2014 Sonian, Inc. and contributors. <support@sensuapp.org>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'json'
require 'open-uri'
require 'openssl'

require 'sensu-plugins-graphite/graphite_proxy/options'
require 'sensu-plugins-graphite/graphite_proxy/proxy'

class CheckGraphiteHosts < Sensu::Plugin::Check::CLI
  include SensuPluginsGraphite::GraphiteProxy::Options

  # Run checks
  def run
    if config[:help]
      puts opt_parser if config[:help]
      exit
    end

    proxy = SensuPluginsGraphite::GraphiteProxy::Proxy.new(config)
    begin
      results = proxy.retrieve_data!

      check(:critical, results) || check(:warning, results)
      ok("#{name} value (#{hosts_with_data(results)}) OK")
    rescue SensuPluginsGraphite::GraphiteProxy::ProxyError => e
      unknown e.message
    end
  end

  # name used in responses
  def name
    base = config[:name]
    @formatted ? "#{base} (#{@formatted})" : base
  end

  # return the number of hosts with data in the given set of results
  def hosts_with_data(resultset)
    resultset.count { |_host, values| !values['data'].empty? }
  end

  # type:: :warning or :critical
  # Return alert if required
  def check(type, results)
    # #YELLOW
    num_hosts = hosts_with_data(results)
    return unless config[type] && threshold_crossed?(type, num_hosts)

    msg = hosts_threshold_message(config[:target], num_hosts, type)
    send(type, msg)
  end

  def threshold_crossed?(type, num_hosts)
    below?(type, num_hosts) || above?(type, num_hosts)
  end

  def hosts_threshold_message(target, hosts, type)
    "Number of hosts sending #{target} (#{hosts}) has passed #{type} threshold (#{config[type]})"
  end

  # Check if value is below defined threshold
  def below?(type, val)
    config[:below] && val < config[type]
  end

  # Check is value is above defined threshold
  def above?(type, val)
    !config[:below] && (val > config[type])
  end
end
