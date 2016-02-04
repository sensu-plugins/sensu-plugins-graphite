#!/usr/bin/env ruby
#
# Copyright 2013 vimov, LLC. <a.gameel@vimov.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'sensu-handler'

class GraphiteOccurrences < Sensu::Handler
  # override filters from Sensu::Handler. not appropriate for metric handlers
  def filter; end

  def handle
    hostname = @event['client']['name']
    # #YELLOW
    check_name = @event['check']['name'].gsub(%r{[ \.]}, '_')
    value = @event['action'] == 'create' ? @event['occurrences'] : 0
    now = Time.now.to_i

    # Get Graphite-like format for Sensu events here
    check_occurrences = "sensu.#{hostname}.#{check_name} #{value} #{now}"

    graphite_server = settings['graphite']['server']
    graphite_port = settings['graphite']['port']

    begin
      timeout(3) do
        sock = TCPSocket.new(graphite_server, graphite_port)
        sock.puts check_occurrences
        sock.close
      end
    rescue Timeout::Error
      puts 'Graphite -- timed out while sending check occurrence'
    rescue => error
      puts "Graphite -- failed to send check occurrence: #{error}"
    end
  end
end
