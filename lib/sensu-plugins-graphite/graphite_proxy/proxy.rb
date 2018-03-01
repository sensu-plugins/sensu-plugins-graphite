require 'open-uri'

module SensuPluginsGraphite
  module GraphiteProxy
    class ProxyError < StandardError
      def initialize(msg)
        super msg
      end
    end

    class Proxy
      attr_accessor :config

      def initialize(config)
        self.config = config
      end

      def formatted_target
        if config[:target].include?('$')
          require 'socket'
          formatted = Socket.gethostbyname(Socket.gethostname).first.gsub('.', config[:hostname_sub] || '_')
          config[:target].gsub('$', formatted)
        else
          URI.escape config[:target]
        end
      end

      def request_auth_options(given_opts)
        url_opts = {}

        url_opts[:ssl_verify_mode] = OpenSSL::SSL::VERIFY_NONE if given_opts[:no_ssl_verify]

        if given_opts[:username]
          pass = derive_password(given_opts)
          url_opts[:http_basic_authentication] = [given_opts[:username], pass.chomp]
        end # we don't have both username and password trying without

        url_opts['Authorization'] = "Bearer #{given_opts[:auth]}" if given_opts[:auth]

        url_opts
      end

      def derive_password(given_opts)
        if given_opts[:passfile]
          File.open(given_opts[:passfile]).readline
        elsif given_opts[:password]
          given_opts[:password]
        end
      end

      def format_output(data)
        output = {}

        data.each do |raw|
          unless raw['datapoints'].empty?
            line = output_line(raw)
            output[line['target']] = line
          end
        end
        output
      end

      def output_line(raw)
        raw['datapoints'].delete_if { |v| v.first.nil? }
        target = raw['target']
        data = raw['datapoints'].map(&:first)
        start = raw['datapoints'].first.last
        dend = raw['datapoints'].last.last
        step = ((dend - start) / raw['datapoints'].size.to_f).ceil

        { 'target' => target, 'data' => data, 'start' => start, 'end' => dend, 'step' => step }
      end

      # grab data from graphite
      def retrieve_data!
        unless @raw_data
          begin
            unless config[:server].start_with?('https://', 'http://')
              config[:server].prepend('http://')
            end

            url = "#{config[:server]}/render?format=json&target=#{formatted_target}&from=#{config[:from]}&until=#{config[:until]}"

            handle = open(url, request_auth_options(config))

            @raw_data = handle.gets
            json_data = JSON.parse(@raw_data)
            format_output(json_data)
          rescue OpenURI::HTTPError
            raise ProxyError, 'Failed to connect to Graphite server'
          rescue NoMethodError, JSON::ParserError
            raise ProxyError, 'No data for time period and/or target'
          rescue Errno::ECONNREFUSED
            raise ProxyError, 'Connection refused when connecting to Graphite server'
          rescue Errno::ECONNRESET
            raise ProxyError, 'Connection reset by peer when connecting to Graphite server'
          rescue EOFError
            raise ProxyError, 'End of file error when reading from Graphite server'
          rescue => e
            raise ProxyError, "An unknown error occurred: #{e.inspect}"
          end
        end
      end
    end
  end
end
