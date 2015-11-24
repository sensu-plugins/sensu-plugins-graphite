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
    if (Time.now.to_i - @value['end']) > config[:allowed_graphite_age] && config[:allowed_graphite_age] != 999
      unknown "Graphite data age is past allowed threshold (#{config[:allowed_graphite_age]} seconds)"
    end
  end

  # grab data from graphite
  def retrieve_data
    unless @raw_data
      begin
        unless config[:server].start_with?('https://', 'http://')
          config[:server].prepend('http://')
        end

        url = "#{config[:server]}/render?format=json&target=#{formatted_target}&from=#{config[:from]}"

        url_opts = {}

        if config[:no_ssl_verify]
          url_opts[:ssl_verify_mode] = OpenSSL::SSL::VERIFY_NONE
        end

        if config[:username] && (config[:password] || config[:passfile])
          if config[:passfile]
            pass = File.open(config[:passfile]).readline
          elsif config[:password]
            pass = config[:password]
          end

          url_opts[:http_basic_authentication] = [config[:username], pass.chomp]
        end # we don't have both username and password trying without

        handle = open(url, url_opts)

        @raw_data = handle.gets
        if @raw_data == '[]'
          unknown 'Empty data received from Graphite - metric probably doesn\'t exists'
        else
          @json_data = JSON.parse(@raw_data)
          output = {}
          @json_data.each do |raw|
            raw['datapoints'].delete_if { |v| v.first.nil? }
            next if raw['datapoints'].empty?
            target = raw['target']
            data = raw['datapoints'].map(&:first)
            start = raw['datapoints'].first.last
            dend = raw['datapoints'].last.last
            step = ((dend - start) / raw['datapoints'].size.to_f).ceil
            output[target] = { 'target' => target, 'data' => data, 'start' => start, 'end' => dend, 'step' => step }
          end
          output
        end
      rescue OpenURI::HTTPError
        unknown 'Failed to connect to graphite server'
      rescue NoMethodError
        unknown 'No data for time period and/or target'
      rescue Errno::ECONNREFUSED
        unknown 'Connection refused when connecting to graphite server'
      rescue Errno::ECONNRESET
        unknown 'Connection reset by peer when connecting to graphite server'
      rescue EOFError
        unknown 'End of file error when reading from graphite server'
      rescue => e
        unknown "An unknown error occured: #{e.inspect}"
      end
    end
  end

  # type:: :warning or :critical
  # Return alert if required
  def check(type)
    if config[type]
      send(type, "#{@value['target']} has passed #{type} threshold (#{@data.last})") if below?(type) || above?(type)
    end
  end

  # Check if value is below defined threshold
  def below?(type)
    if ! @data.nil?
      config[:below] && @data.last < config[type]
    end
  end

  # Check is value is above defined threshold
  def above?(type)
    if ! @data.nil?
      (!config[:below]) && (@data.last > config[type]) && (!decreased?)
    end
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
