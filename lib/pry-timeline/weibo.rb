# encoding : utf-8

module PryTimeline
  class Weibo < Service
    def initialize(opts = {})
      api_backed = 'https://api.weibo.com'
      
      super(api_backed, opts)
    end

    def home_timeline(args = {})
      resp = api.get '/2/statuses/home_timeline.json', (params.merge args)

      parse_resp(resp)['statuses']
    end

    def status_update(status, args={})
      unless len_little_then? status
        raise APIError.new('text length over 140.')
      end

      args['status'] = status

      resp = api.post '/2/statuses/update.json', (params.merge args) 
      parse_resp(resp)['id']
    end

    def login
      code = get_authorize_code('/oauth2/authorize')

      init_token('/oauth2/access_token', 'code' => code)

      token = read_token || {}
      if token['access_token']
        return token['access_token']
      end
    end

    def parse_resp(response)
      result = JSON.parse(response.body)

      if result.keys.include? 'error'
        raise APIError.new(result)
      end

      result
    end

    def time_marker(status)
      #super(status)
      DateTime.parse(status['created_at'])
    end

    def len_little_then?(text, limit = 140)
      text.length <= limit ? true : false
    end
  end
end