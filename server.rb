require 'socket'

server = TCPServer.new('localhosttie', 3003)
loop do
  client = server.accept
  request_line = client.gets
  next if !request_line || request_line =~ /favicon/

  client.puts "HTTP/1.1 200 OK"
  client.puts "Content-Type: text/plain"
  client.puts
  client.puts <<~HTML
              <html>
                <body>
                <p><em>Hello World!</em></p>
                </body>
              </html>
              HTML

  client.close
end