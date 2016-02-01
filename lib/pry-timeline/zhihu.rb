# encoding : utf-8

module PryTimeline
  module Parser
    Feed = Struct.new(
        :user,
        :title,
        #:summary,
        :created_at,
        :href
      )

    def parse(page)
      feeds = []

      raw_feeds = page.at("#js-home-feed-list").search("div[id*='feed-']")
      raw_feeds.each do |feed|
        feeds << ext_single_feed(feed)
      end

      feeds
    end

    def ext_single_feed(node)
      Feed.new.tap do |f|
        f.members.each do |member|
          f.send("#{member}=", eval("ext_#{member.to_s.downcase}(node)"))
        end
      end
    end

    def ext_user(node)
      node.at(".source .zg-link").text
    end

    def ext_title(node)
      node.at(".content h2").text
    end

    def ext_created_at(node)
      node.at(".source .time").text
    end

    def ext_href(node)
      node.at(".content h2 a").attributes['href'].value
    end
  end

  class Zhihu < Service
    include Parser

    def initialize(opts = {})
      @options = opts
    end

    def home_timeline
      home_page = agent.get('https://m.zhihu.com/')

      # unless login?(home_page)
      #   login
      # end

      parse(home_page).map(&:to_h).map do |feed|
        feed.inject({}) do |n_hash, (k, v)|
          n_hash[k.to_s] = v
          n_hash
        end
      end
    end

    def time_marker(status)
      raw_time = status['created_at']

      span = Rational(0)
      if raw_time =~ /(\d*)/
        if raw_time.index '分钟'
          span = Rational($1.to_i, 24 * 60)
        elsif raw_time.index '小时'
          span = Rational($1.to_i, 24)
        elsif raw_time.index '天'
          span = Rational($1.to_i)
        end
      end

      DateTime.now - span
    end

    def login
      page = agent.get('http://m.zhihu.com/#signin')

      params = {
        '_xsrf' => page.form.fields[0].value,
        'password' => @options['password'],
        'email' => @options['email'],
        'remember_me' => 'true'
      }

      resp = agent.post 'http://m.zhihu.com/login/email', params
      result = JSON.parse(resp.body)
      puts result['msg']
      if result['r'] == 0
        agent.cookie_jar.save @options['cookie_file'] 
      end
    end

    def login?(page = nil)
      page ||= agent.get('https://m.zhihu.com/')

      page.at('.zu-top') ? false : true
    end

    def agent
      @agent ||= Mechanize.new.tap { |agent|
        agent.user_agent_alias = 'Linux Mozilla'
        agent.cookie_jar.load(@options['cookie_file'])
      }
    end
  end
end