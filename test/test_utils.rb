# encoding : utf-8

require 'minitest/autorun'
require 'pry-timeline'

class PryUtilsTest < Minitest::Test
  include PryTimeline

  def setup
    CLI::WeiboClient.options['token_file'] = File.join Dir.home, '.pry-timeline-test'
  end

  def test_save_and_read_token
    token = {:a => '111', :b=> '222'}
    CLI::WeiboClient.save_token(token)

    assert CLI::WeiboClient.read_token, token
  end

  def test_save_and_read_token
    token = {:a => '111', :b=> '222'}
    token2 = {:a => '111', :b=> '222'}
    CLI::WeiboClient.save_token(token)
    CLI::WeiboClient.save_token(token2)

    assert_operator CLI::WeiboClient.read_token.size, :>=, 2
  end
end