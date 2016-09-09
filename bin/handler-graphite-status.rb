#!/usr/bin/env ruby
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details
#
# This will send the check status (0,1,2,3) to a graphite metric when a check event state changes
# Based on handler-graphite-notify.rb
# See http://imansson.wordpress.com/2012/11/26/why-sensu-is-a-monitoring-router-some-cool-handlers/

require 'sensu-handler'
require 'simple-graphite'

class Resolve < Sensu::Handler
  # override filters from Sensu::Handler. not appropriate for metric handlers
  def filter; end

  def handle
    port = settings['graphite_notify']['port'] ? settings['graphite_notify']['port'].to_s : '2003'
    graphite = Graphite.new(host: settings['graphite_notify']['host'], port: port)
    return unless graphite
    prop = @event['check']['status']
    message = "#{settings['graphite_notify']['prefix']}.#{@event['client']['name'].tr('.', '_')}.#{@event['check']['name']}"
    message += " #{prop} #{graphite.time_now + rand(100)}"
    begin
      graphite.push_to_graphite do |graphite_socket|
        graphite_socket.puts message
      end
    rescue => e
      error_msg = "Can't connect to #{settings['graphite_notify']['host']}:#{port} and send message #{message}: #{e}'"
      raise error_msg
    end
  end
end
