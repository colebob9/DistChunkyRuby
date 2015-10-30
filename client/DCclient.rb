#!/usr/bin/env ruby -w

# travis ci stuff
group :test do
  gem 'rake'
end

require "socket"
puts "DistChunky Client vX.X.X"
puts "Written by colebob9"
puts
class Client
  def initialize( server )
    @server = server
    @request = nil
    @response = nil
    listen
    send
    @request.join
    @response.join
  end

  def listen
    @response = Thread.new do
      loop {
        msg = @server.gets.chomp
        puts "#{msg}"
      }
    end
  end

  def send
    puts "Enter the username:"
    @request = Thread.new do
      loop {
        msg = $stdin.gets.chomp
        @server.puts( msg )
      }
    end
  end
end

print "Server's IP address? (put localhost if hosted on the same PC): "
serverip = gets.chomp
server = TCPSocket.open( "#{serverip}", 3000 )
Client.new( server )