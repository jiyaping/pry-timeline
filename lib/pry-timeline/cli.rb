# encoding : utf-8

module PryTimeline
  class CLI
    class << self
      def login(service)
        if OPTIONS['services'].include? service
          raise BasicError.new('login service not found')
        end

        client = clients.select do |client|
          eval(svc.capitalize) === client
        end.first

        client.login unless client.nil?
      end

      def timeline(args = {})
        msg_stack = []

        clients.each do |client|
          client.home_timeline.each do |status|
            formatter = client.formatter

            msg_stack << {
              formatter.format(status) => client.time_marker(status)
            }
          end
        end

        msg_stack.sort_by{ |h| h.values.last }.map do |item|
          item.keys.first
        end.reverse
      end

      def clients
        @clients ||= OPTIONS['services'].map do |svc|
          begin
            eval(svc.capitalize).new(OPTIONS['authen'][svc])
          rescue Exception => e
            raise BasicError.new('create services failed.' + e.message)
          end
        end
      end
    end
  end
end