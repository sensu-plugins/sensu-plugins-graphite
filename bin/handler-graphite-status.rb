#!/usr/bin/env ruby
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details
#
# This will send the check status (0,1,2,3) to a graphite metric when a check event state changes
# Based on handler-graphite-notify.rb.
# Config by default is graphite_status but can be called with a specific json config
# using the -j option. This allows multiple graphite handlers to be configured.

require 'sensu-handler'
require 'simple-graphite'

class Resolve < Sensu::Handler
  option :json_config,
         description: 'Config Name',
         short: '-j JsonConfig',
         long: '--json_config JsonConfig',
         required: false,
         default: 'graphite_status'
  # override filters from Sensu::Handler. not appropriate for metric handlers
  def filter; end

  def handle
    json_config = config[:json_config]
    port = settings[json_config]['port'] ? settings[json_config]['port'].to_s : '2003'
    graphite = Graphite.new(host: settings[json_config]['host'], port: port)
    return unless graphite
    prop = @event['check']['status']
    message = "#{settings[json_config]['prefix']}.#{@event['client']['name'].tr('.', '_')}.#{@event['check']['name']}"
    message += " #{prop} #{graphite.time_now + rand(100)}"
    begin
      graphite.push_to_graphite do |graphite_socket|
        graphite_socket.puts message
      end
    rescue ETIMEDOUT
      error_msg = "Can't connect to #{settings[json_config]['host']}:#{port} and send message #{message}'"
      raise error_msg
    end
  end
end
