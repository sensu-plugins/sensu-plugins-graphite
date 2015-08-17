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
require 'byebug'

require 'sensu-plugins-graphite/graphite_proxy/options'

class CheckGraphiteHosts < Sensu::Plugin::Check::CLI

  include SensuPluginsGraphite::GraphiteProxy::Options
  # option :target,
  #        description: 'Graphite data target',
  #        short: '-t TARGET',
  #        long: '--target TARGET',
  #        required: true

  # option :server,
  #        description: 'Server host and port',
  #        short: '-s SERVER:PORT',
  #        long: '--server SERVER:PORT',
  #        required: true

  # option :username,
  #        description: 'username for basic http authentication',
  #        short: '-u USERNAME',
  #        long: '--user USERNAME',
  #        required: false

  # option :password,
  #        description: 'user password for basic http authentication',
  #        short: '-p PASSWORD',
  #        long: '--pass PASSWORD',
  #        required: false

  # option :passfile,
  #        description: 'password file path for basic http authentication',
  #        short: '-P PASSWORDFILE',
  #        long: '--passfile PASSWORDFILE',
  #        required: false

  # option :no_ssl_verify,
  #        description: 'Do not verify SSL certs',
  #        short: '-v',
  #        long: '--nosslverify'

  # option :help,
  #        description: 'Show this message',
  #        short: '-h',
  #        long: '--help'

  # option :auth,
  #        description: 'Add an auth token to the HTTP request, in the form of "Name: Value",
  #                                    e.g. --auth yourapitokenvaluegoeshere',
  #        short: '-a TOKEN',
  #        long: '--auth TOKEN'

  # option :name,
  #        description: 'Name used in responses',
  #        short: '-n NAME',
  #        long: '--name NAME',
  #        default: 'graphite check'

  # option :allowed_graphite_age,
  #        description: 'Allowed number of seconds since last data update (default: 60 seconds)',
  #        short: '-a SECONDS',
  #        long: '--age SECONDS',
  #        default: 60,
  #        proc: proc(&:to_i)

  # option :hostname_sub,
  #        description: 'Character used to replace periods (.) in hostname (default: _)',
  #        short: '-s CHARACTER',
  #        long: '--host-sub CHARACTER'

  # option :from,
  #        description: 'Get samples starting from FROM (default: -10mins)',
  #        short: '-f FROM',
  #        long: '--from FROM',
  #        default: '-10mins'

  # option :warning,
  #        description: 'Generate warning if number of hosts is below received value',
  #        short: '-w VALUE',
  #        long: '--warn VALUE',
  #        proc: proc(&:to_f)

  # option :critical,
  #        description: 'Generate critical if number of hosts is below received value',
  #        short: '-c VALUE',
  #        long: '--critical VALUE',
  #        proc: proc(&:to_f)

  # option :below,
  #        description: 'alert if number of hosts below specified thresholds',
  #        short: '-b',
  #        long: '--below'

  # Run checks
  def run
    if config[:help]
      puts opt_parser if config[:help]
      exit
    end

    results = retrieve_data
    check_age(results) || check(:critical, results) || check(:warning, results)
  
    ok("#{name} value (#{hosts_with_data(results)}) okay")
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

  def format_url_opts(given_opts)
    url_opts = {}

    if given_opts[:no_ssl_verify]
      url_opts[:ssl_verify_mode] = OpenSSL::SSL::VERIFY_NONE
    end

    if given_opts[:username] && (given_opts[:password] || given_opts[:passfile])
      if given_opts[:passfile]
        pass = File.open(given_opts[:passfile]).readline
      elsif given_opts[:password]
        pass = given_opts[:password]
      end

      url_opts[:http_basic_authentication] = [given_opts[:username], pass.chomp]
    end # we don't have both username and password trying without

    if given_opts[:auth]
      header = "Bearer #{given_opts[:auth]}"
      url_opts['Authorization'] = header
    end

    url_opts
  end

  def format_output
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

  # grab data from graphite
  def retrieve_data
    # #YELLOW
    unless @raw_data # rubocop:disable GuardClause
      begin
        unless config[:server].start_with?('https://', 'http://')
          config[:server].prepend('http://')
        end

        url = "#{config[:server]}/render?format=json&target=#{formatted_target}&from=#{config[:from]}"

        handle = open(url, format_url_opts(config))

        @raw_data = handle.gets
        if @raw_data == '[]'
          unknown 'Empty data received from Graphite - metric probably doesn\'t exists'
        else
          @json_data = JSON.parse(@raw_data)
          format_output
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

  # Returns formatted target with hostname replacing any $ characters
  def formatted_target
    if config[:target].include?('$')
      require 'socket'
      @formatted = Socket.gethostbyname(Socket.gethostname).first.gsub('.', config[:hostname_sub] || '_')
      config[:target].gsub('$', @formatted)
    else
      URI.escape config[:target]
    end
  end
end
