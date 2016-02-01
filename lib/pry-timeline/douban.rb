# encoding : utf-8

module PryTimeline
  class Douban < Service
    def initialize(opts = {})
      api_backed = 'https://api.douban.com'

      super(api_backed, opts)
    end

    def home_timeline(args = {})
      resp = api.get do |req|
        req.url '/shuo/v2/statuses/home_timeline'
        req.headers['Authorization'] = "Bearer #{params['access_token']}"
      end

      parse_resp resp
    end

    def login
      code = get_authorize_code('https://www.douban.com/service/auth2/auth')

      init_token('/service/auth2/token', 'code' => code)

      token = read_token || {}
      if token['access_token']
        return token['access_token']
      end
    end

    def time_marker(status)
      DateTime.parse(status['created_at'] + "UTC+8")
    end

    def parse_resp(response)
      result = JSON.parse(response.body)

      if Hash === result && result['code']
        raise APIError.new('code'=>result['code'], 'error_code'=> result['msg'])
      end

      result
    end

    def get_authorize_code(path)
      args = {
        'client_id' => options['app_key'],
        'redirect_uri' => options['redirect_uri'],
        'response_type' => 'code',
      }

      query_str = args.inject('') do |query_str, values|
         query_str += "#{values[0]}=#{values[1]}&"
      end

      url = "#{path}?#{query_str}"
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
        'redirect_uri' => options['redirect_uri'],
        'grant_type' => 'authorization_code',
        'code' => args['code'],
      }

      resp = Faraday.new('https://www.douban.com').post path, opts
      save_token(parse_resp(resp))
    end
  end
end