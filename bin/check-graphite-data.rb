#! /usr/bin/env ruby
#
#   check-data
#
# DESCRIPTION:
#   This plugin checks values within graphite
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

class CheckGraphiteData < Sensu::Plugin::Check::CLI

  include SensuPluginsGraphite::GraphiteProxy::Options

  option :reset_on_decrease,
    description: 'Send OK if value has decreased on any values within END-INTERVAL to END',
    short: '-r INTERVAL',
    long: '--reset INTERVAL',
    proc: proc(&:to_i)

  option :allowed_graphite_age, 
         description: 'Allowed number of seconds since last data update (default: 60 seconds)',
         short: '-a SECONDS',
         long: '--age SECONDS',
         default: 60,
         proc: proc(&:to_i)

  # Run checks
  def run
    if config[:help]
      puts opt_parser if config[:help]
      exit
    end

    proxy = SensuPluginsGraphite::GraphiteProxy::Proxy.new(config)
    begin
      results = proxy.retrieve_data!
      results.each_pair do |_key, value|
        @value = value
        @data = value['data']
        check_age || check(:critical) || check(:warning)
      end

      ok("#{name} value okay")
    rescue SensuPluginsGraphite::GraphiteProxy::ProxyError => e
      unknown e.message
    end
  end

  # name used in responses
  def name
    base = config[:name]
    @formatted ? "#{base} (#{@formatted})" : base
  end

  # Check the age of the data being processed
  def check_age
    # #YELLOW
    if (Time.now.to_i - @value['end']) > config[:allowed_graphite_age] # rubocop:disable GuardClause
      unknown "Graphite data age is past allowed threshold (#{config[:allowed_graphite_age]} seconds)"
    end
  end

  # type:: :warning or :critical
  # Return alert if required
  def check(type)
    # #YELLOW
    if config[type] # rubocop:disable GuardClause
      send(type, "value (#{@data.last}) for #{@value['target']} has passed #{type} threshold (#{config[type]})") if below?(type) || above?(type)
    end
  end

  # Check if value is below defined threshold
  def below?(type)
    config[:below] && @data.last < config[type]
  end

  # Check is value is above defined threshold
  def above?(type)
    (!config[:below]) && (@data.last > config[type]) && (!decreased?)
  end

  # Check if values have decreased within interval if given
  def decreased?
    if config[:reset_on_decrease]
      slice = @data.slice(@data.size - config[:reset_on_decrease], @data.size)
      val = slice.shift until slice.empty? || val.to_f > slice.first
      !slice.empty?
    else
      false
    end
  end

end
