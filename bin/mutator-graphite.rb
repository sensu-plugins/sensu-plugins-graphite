#!/usr/bin/env ruby
#
# Graphite
# ===
#
# DESCRIPTION:
#   This mutator is an extension of the OnlyCheckOutput mutator, but
#   modified for Graphite metrics. This mutator only sends event output
#   (so you don't need to use OnlyCheckOutput) and it also modifies
#   the format of the hostname in the output if present.
#
#   Note however that using this mutator as an mutator command can be very
#   expensive, as Sensu has to spawn a new Ruby process to launch this script
#   for each result of a metrics check. Consider instead to produce the correct
#   metric names from your plugin and send them directly to Graphite via the
#   socket handler.
#   See https://groups.google.com/d/msg/sensu-users/1hkRSvL48ck/8Dhl98lR24kJ
#   for more information.
#
# OUTPUT:
#   Sensu event output with all dots changed to underlines in host name
#   If -r or --reverse parameter given script put hostname in reverse order
#   for better graphite tree view
#
# PLATFORM:
#   all
#
# DEPENDENCIES:
#   none
#
# Copyright 2013 Peter Kepes <https://github.com/kepes>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.
require 'json'

# parse event
event = JSON.parse(STDIN.read, symbolize_names: true)

if ARGV[0] == '-r' || ARGV[0] == '--reverse'
  puts event[:check][:output].gsub(event[:client][:name], event[:client][:name].split('.').reverse.join('.'))
else
  puts event[:check][:output].gsub(event[:client][:name], event[:client][:name].gsub('.', '_'))
end
