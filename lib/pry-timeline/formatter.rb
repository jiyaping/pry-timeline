# encoding : utf-8

module PryTimeline
  class Formatter
    attr_accessor :text, :color

    # text = "%['id'] %['text']"
    # color = {'id'=> 'red on_blue', 'content'=> 'underline'}
    def initialize(service, args = {})
      @text = args['text']
      @color= args['color']

      @service = service.to_s.split("::").last.downcase
    end

    def format(hash)
      hash = colorize(hash)

      heading + hash.instance_eval(@text.gsub(/%(\[\S*\])/, 'self\1'))
    end
    alias :to_s :format

    def heading(style = PryTimeline::OPTIONS['heading'])
      default_heading_style = {
        'douban' => 'DB'.light_white.on_light_green,
        'zhihu' => 'ZH'.light_white.on_light_blue,
        'weibo' => 'WB'.light_white.on_light_red,
        'twitter' => 'WT'.light_white.on_light_cyan,
        'facebook' => 'FB'.light_white.on_blue,
      }

      default_heading_style.merge! (style || {})
      default_heading_style[@service]
    end

    def colorize(hash)
      @color.each do |key, value|
        color_attr = "#{value.split(' ').join('.')}"
        if Array === value
          color_attr = "#{value.join('.')}"
        end

        if key_arr = key.split('/').compact.reject(&:empty?)
          origin_key = key_arr.last
          origin_value = key_arr.inject(hash, :fetch)

          key_arr[0...-1].inject(hash, :fetch)[origin_key] = origin_value.instance_eval(
              "self.to_s.#{color_attr}"
            )
        end
      end

      hash
    end
  end
end