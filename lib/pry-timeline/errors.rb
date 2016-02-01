# encoding : utf-8

module PryTimeline
  class BasicError < StandardError; end
  class AuthenticationError < BasicError; end
  class APIError < BasicError
    def initialize(args={})
      @error_code = args['error_code']
      @error      = args['error']

      super
    end

    def to_s
      "#{@error_code} : @error"
    end
  end
end