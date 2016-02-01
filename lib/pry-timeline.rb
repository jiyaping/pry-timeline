# encoding : utf-8

require 'pry'
require 'faraday'
require 'json'
require 'colorize'
require 'securerandom'
require 'digest'
require 'yaml'
require 'net/http'
require 'mechanize'

require 'pry-timeline/utils'
require 'pry-timeline/errors'
require 'pry-timeline/embeded_server'
require 'pry-timeline/auth'
require 'pry-timeline/service'
require 'pry-timeline/formatter'
require 'pry-timeline/douban'
require 'pry-timeline/weibo'
require 'pry-timeline/zhihu'
require 'pry-timeline/version'

#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

module PryTimeline
  DEFAULT_OPTS = {
    'services' => ['weibo', 'douban','zhihu'],
    'authen' => {
      'weibo' => {
        'app_key' => '412175710',
        'app_secret' => '61d011f1800468d49c500008695104d0',
        'token_file' => File.join(Dir.home, '.pry-timeline'),
        'redirect_uri' => 'http://127.0.0.1:23333',
        'formatter' => {
          'text' => "'@'+%['user']['name'] + \"\n\" + %['text'] + \"\n\n\"",
          'color' => {
            'text' => 'black',
            'user/name' => 'light_red',
            'reposts_count' => 'light_white on_red',
            'comments_count' => 'light_white on_blue',
            'attitudes_count' => 'light_white on_green',
          }
        }
      },
      'douban' => {
        'app_key' => '0fec79487006ba7e2fc56bd950142f7a',
        'app_secret' => 'f7e4cfb6b23b1d80',
        'token_file' => File.join(Dir.home, '.pry-timeline'),
        'redirect_uri' => 'http://127.0.0.1:23333',
        'formatter' => {
          'text' => "'@' + %['user']['screen_name'] + \"\n\" + \
                     %['title'] + '  ' + %['text'] +\
                     %['attachments'][0]['title'] + \"\n\n\"",
          'color' => {
            'title' => 'magenta',
            'user/screen_name' => 'light_green',
          }
        }
      },
      'zhihu' => {
        'email' => 'xxxxxxxx@gmail.com',
        'password' => 'xxxxxxxxxxx',
        'cookie_file' => File.join(Dir.home, '.zhihu'),
        'formatter' => {
          'text'=> "'@' + %['user'] + \"\n\"\
          + %['title'] + %['href'] + \"\n\n\"",
          'color' => {
            'user' => 'light_blue',
            'href' => 'blue'
          }
        }
      }
    }
  }

  OPTIONS = DEFAULT_OPTS.merge (Pry.config.timeline || {})
end

Pry::Commands.create_command "timeline" do
  def options(opt)
    opt.on :l, :login, "login with specify account",true do |l|
      @login = l
    end
  end

  def process
    if opts.login?
      PryTimeline::CLI.login args.first
    else
      PryTimeline::CLI.timeline
    end
  end
end

require 'pry-timeline/cli'