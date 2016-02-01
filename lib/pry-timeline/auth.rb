# encoding : utf-8

module PryTimeline
  module Authentication
    def login?
      token = read_token || {}

      if token['access_token']
        return true
      end

      false
    end

    def get_authorize_code(path, args = {})
      opts = {
        'client_id' => options['app_key'],
        'redirect_uri' => options['redirect_uri']
      }

      opts = opts.merge args
      query_str = opts.inject('') do |query_str, values|
         query_str += "#{values[0]}=#{values[1]}&"
      end

      url = File.join @api_backend, "#{path}?#{query_str}"
      # puts url
      PryTimeline.open_browser url

      while authorize_code = EmbededServer.start(options['redirect_uri'])
        return authorize_code
      end
    end

    def init_token(path, args = {})
      opts = {
        'client_id' => options['app_key'],
        'client_secret' => options['app_secret'],
        'grant_type' => 'authorization_code',
        'redirect_uri' => options['redirect_uri']
      }

      opts = opts.merge args

      resp = api.post path, opts
      save_token(parse_resp(resp))
    end

    def parse_resp(response)
      result = JSON.parse(response.body)

      if result.keys.include? 'error'
        raise APIError.new(result)
      end

      result
    end

    def read_token()
      svc_class = self.class.to_s.downcase.to_sym
      f = File.open(options['token_file'], 'r')

      if data = YAML.load(f)
        data[svc_class]
      else
        raise AuthenticationError.new('uninitialize token. You should login first.')
      end
    end

    def save_token(token)
      svc_class = self.class.to_s.downcase.to_sym

      file = File.open(options['token_file'], 'r')
      data = YAML.load(file) || {}
      File.open(options['token_file'], 'w+') do |f|
        data[svc_class] = token
        YAML.dump(data, f)
      end
    end
  end
end