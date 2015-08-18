#! /usr/bin/env ruby
#
#   check-graphite-hosts
#
# DESCRIPTION:
#   This plugin checks the number of hosts within graphite that are sending
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
#   gem: openssl
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
      check_age(results) || check(:critical, results) || check(:warning, results)
  
      ok("#{name} value (#{hosts_with_data(results)}) okay")
    rescue SensuPluginsGraphite::GraphiteProxy::ProxyException => e
      puts e.backtrace
      unknown e.message
    end
  end

  # name used in responses
  def name
    base = config[:name]
    @formatted ? "#{base} (#{@formatted})" : base
  end

  # Check the age of the data being processed
  def check_age(results)
    # #YELLOW
    hosts_too_old = results.select{|host, values| (Time.now.to_i - values['end']) > config[:allowed_graphite_age] }
    hosts_too_old.each do |host, values|
      if (Time.now.to_i - @value['end']) > config[:allowed_graphite_age] # rubocop:disable GuardClause
        return unknown "Graphite data age for host #{host} is past allowed threshold (#{config[:allowed_graphite_age]} seconds)"
      end
    end
    nil
  end

  # return the number of hosts with data in the given set of results
  def hosts_with_data(resultset)
    resultset.select{|host, values| !values["data"].empty?}.size
  end

  # type:: :warning or :critical
  # Return alert if required
  def check(type, results)
    # #YELLOW
    num_hosts = hosts_with_data(results)
    if config[type] # rubocop:disable GuardClause
      send(type, "Number of hosts sending #{config[:target]} (#{num_hosts}) has passed #{type} threshold (#{config[type]})") if below?(type, num_hosts) || above?(type, num_hosts)
    end
  end

  # Check if value is below defined threshold
  def below?(type, val)
    config[:below] && val < config[type]
  end

  # Check is value is above defined threshold
  def above?(type, val)
    (!config[:below]) && (val > config[type]) 
  end

end
