# encoding : utf-8

module PryTimeline
  # EmbededServer used to read authorize code
  class EmbededServer
    def self.start(uri)
      url = URI.parse(uri)

      server =  TCPServer.new(url.host, url.port)
      loop do
        socket = server.accept
        line = socket.gets
        resp = response
        socket.print  "HTTP/1.1 200 OK\r\n" +
                      "Content-Type: text/html\r\n" +
                      "Content-Length: #{resp.bytesize}\r\n" +
                      "Connection: close\r\n"
        socket.print "\r\n"
        socket.print resp
        socket.close

        if line.split(' ')[1] =~ /=(\S*)/
          return $1 if $1
        end
      end
    end

    def self.response
      str=<<RESP
<html>
  <head>
  </head>
  <title></title>
  <body>
  <h4>Authroize Success</h4>
  </body>
</html>
RESP
      str
    end
  end
end