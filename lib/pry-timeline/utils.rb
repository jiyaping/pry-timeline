# encoding : utf-8

module PryTimeline
  class << self
    def open_browser(url)
      if windows?
        system "start \"\" \"#{url}\""
      elsif macos?
        system "open #{url}"
      elsif linux?
        system "xdg-open #{url}"
      else
        raise BasicError.new('unspported platform.')
      end
    end

    def windows?
      RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
    end

    def macos?
      RbConfig::CONFIG['host_os'] =~ /darwin/
    end

    def linux?
      RbConfig::CONFIG['host_os'] =~ /linux|bsd/
    end
  end
end