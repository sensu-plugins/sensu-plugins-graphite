#!/usr/bin/env ruby
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details
#
# This will send a 1 to a Graphite metric when an event is created and 0 when it's resolved
# See http://imansson.wordpress.com/2012/11/26/why-sensu-is-a-monitoring-router-some-cool-handlers/
#
# Config by default is graphite_notify, but can be called with a specific json config
# using the -j option. This allows multiple graphite handlers to be configured.

require 'sensu-handler'
require 'simple-graphite'

class Resolve < Sensu::Handler
  option :json_config,
         description: 'Config Name',
         short: '-j JsonConfig',
         long: '--json_config JsonConfig',
         required: false,
         default: 'graphite_notify'

  def handle
    json_config = config[:json_config]
    port = settings[json_config]['port'] ? settings[json_config]['port'].to_s : '2003'
    graphite = Graphite.new(host: settings[json_config]['host'], port: port)
    return unless graphite
    prop = @event['action'] == 'create' ? 1 : 0
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
