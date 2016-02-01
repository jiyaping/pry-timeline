# encoding : utf-8

module PryTimeline
  class Service
    include Authentication

    attr_accessor :api_backend, :options

    def initialize(api, args = {})
      @api_backend = api
      @options = args
    end

    def formatter
      @formatter ||= Formatter.new(self.class, @options['formatter'])
    end

    def time_marker(status)
      DateTime.now
    end

    def api(args = {})
      @api ||= Faraday.new(@api_backend)
    end

    def params(fields = [], args = {})
      default_fields = ['access_token']
      fields = (default_fields + fields).uniq
      opts = options.merge args

      opts['access_token'] = token

      opts.select do |key, _|
        fields.include? key
      end
    end

    def token
      options['access_token'] ||= read_token['access_token']
    end
  end
end