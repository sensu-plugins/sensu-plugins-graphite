#!/usr/bin/env ruby
#
# Sensu - Graphite Event Handler
#
# This handler takes events and POSTs them to a Graphite events URI.
#
# For configuration see: graphite_event.json
#
# See here for more details:
#
# * https://code.launchpad.net/~lucio.torre/graphite/add-events/+merge/69142
#
# Author: Rob Wilson <roobert@gmail.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details

require 'sensu-handler'
require 'net/http'
require 'net/https'
require 'uri'
require 'json'

class GraphiteEvent < Sensu::Handler
  option :tags_as_arrays,
         description: 'send tags as array - for post graphite 1.0 compatibility.',
         short: '-t',
         long: '--tags-as-array',
         boolean: true,
         required: false,
         default: false

  def post_event(uri, body)
    uri          = URI.parse(uri)
    req          = Net::HTTP::Post.new(uri.path)
    sock         = Net::HTTP.new(uri.host, uri.port)
    sock.use_ssl = uri.scheme == 'https'
    req.body     = body

    req.basic_auth(uri.user, uri.password) if uri.user

    sock.start { |http| http.request(req) }
  end

  def event_status
    case @event['check']['status']
    when 0
      'ok'
    when 1
      'warning'
    when 2
      'critical'
    else
      'unknown'
    end
  end

  def handle
    tags = [
      'sensu',
      'event',
      event_status,
      @event['client']['name'],
      @event['check']['name']
    ]

    tags += settings['graphite_event']['tags'] if settings['graphite_event']['tags']

    body = {
      'what' => 'sensu_event',
      'tags' => config[:tags_as_array] ? [tags.join(',')] : tags.join(','),
      'data' => event_status,
      'when' => Time.now.to_i
    }

    uri = settings['graphite_event']['server_uri']

    begin
      post_event(uri, body.to_json)
    rescue => e
      bail "failed to send event to #{uri}: #{e}"
    end

    puts "sent event to Graphite: #{body.to_json}"
  end
end
