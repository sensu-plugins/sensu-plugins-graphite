module SensuPluginsGraphite
  module GraphiteProxy
    module Options
      def self.included(base)
        add_default_options(base)
      end

      def self.add_default_options(base)
        default_options.each do |name, vals|
          base.send(:option, name, vals)
        end
      end

      def self.default_options
        {
          target: {
            description: 'Graphite data target',
            short: '-t TARGET',
            long: '--target TARGET',
            required: true
          },

          server: {
            description: 'Server host and port',
            short: '-s SERVER:PORT',
            long: '--server SERVER:PORT',
            required: true
          },

          username: {
            description: 'username for basic http authentication',
            short: '-u USERNAME',
            long: '--user USERNAME',
            required: false
          },

          password: {
            description: 'user password for basic http authentication',
            short: '-p PASSWORD',
            long: '--pass PASSWORD',
            required: false
          },

          passfile: {
            description: 'password file path for basic http authentication',
            short: '-P PASSWORDFILE',
            long: '--passfile PASSWORDFILE',
            required: false
          },

          no_ssl_verify: {
            description: 'Do not verify SSL certs',
            short: '-v',
            long: '--nosslverify'
          },

          help: {
            description: 'Show this message',
            short: '-h',
            long: '--help'
          },

          auth: {
            description: 'Add an auth token to the HTTP request, in the form of "Name: Value",
                                             e.g. --auth yourapitokenvaluegoeshere',
            short: '-a TOKEN',
            long: '--auth TOKEN'
          },

          name: {
            description: 'Name used in responses',
            short: '-n NAME',
            long: '--name NAME',
            default: 'graphite check'
          },

          hostname_sub: {
            description: 'Character used to replace periods (.) in hostname (default: _)',
            short: '-s CHARACTER',
            long: '--host-sub CHARACTER'
          },

          from: {
            description: 'Get samples starting from FROM (default: -10mins)',
            short: '-f FROM',
            long: '--from FROM',
            default: '-10mins'
          },

          warning: {
            description: 'Generate warning if number of hosts is below received value',
            short: '-w VALUE',
            long: '--warn VALUE',
            proc: proc(&:to_f)
          },

          critical: {
            description: 'Generate critical if number of hosts is below received value',
            short: '-c VALUE',
            long: '--critical VALUE',
            proc: proc(&:to_f)
          },

          below: {
            description: 'alert if number of hosts below specified thresholds',
            short: '-b',
            long: '--below'
          }
        }
      end
    end
  end
end
