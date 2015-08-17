module SensuPluginsGraphite
  module GraphiteProxy
    module Options

      def included(base)
        base.send(:extend, ClassMethods)
        byebug
        base.send(:define_options)
      end

      module ClassMethods
        def define_options
          option :target,
             description: 'Graphite data target',
             short: '-t TARGET',
             long: '--target TARGET',
             required: true

          option :server,
                 description: 'Server host and port',
                 short: '-s SERVER:PORT',
                 long: '--server SERVER:PORT',
                 required: true

          option :username,
                 description: 'username for basic http authentication',
                 short: '-u USERNAME',
                 long: '--user USERNAME',
                 required: false

          option :password,
                 description: 'user password for basic http authentication',
                 short: '-p PASSWORD',
                 long: '--pass PASSWORD',
                 required: false

          option :passfile,
                 description: 'password file path for basic http authentication',
                 short: '-P PASSWORDFILE',
                 long: '--passfile PASSWORDFILE',
                 required: false

          option :no_ssl_verify,
                 description: 'Do not verify SSL certs',
                 short: '-v',
                 long: '--nosslverify'

          option :help,
                 description: 'Show this message',
                 short: '-h',
                 long: '--help'

          option :auth,
                 description: 'Add an auth token to the HTTP request, in the form of "Name: Value",
                                             e.g. --auth yourapitokenvaluegoeshere',
                 short: '-a TOKEN',
                 long: '--auth TOKEN'

          option :name,
                 description: 'Name used in responses',
                 short: '-n NAME',
                 long: '--name NAME',
                 default: 'graphite check'

          option :allowed_graphite_age,
                 description: 'Allowed number of seconds since last data update (default: 60 seconds)',
                 short: '-a SECONDS',
                 long: '--age SECONDS',
                 default: 60,
                 proc: proc(&:to_i)

          option :hostname_sub,
                 description: 'Character used to replace periods (.) in hostname (default: _)',
                 short: '-s CHARACTER',
                 long: '--host-sub CHARACTER'

          option :from,
                 description: 'Get samples starting from FROM (default: -10mins)',
                 short: '-f FROM',
                 long: '--from FROM',
                 default: '-10mins'
        end
      end
    end
  end
end