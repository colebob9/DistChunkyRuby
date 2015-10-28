#!/usr/bin/env ruby -w
# defining classes and methods first
require "socket"
require "FileUtils"
puts "Starting up..."
class Server
  def initialize( port, ip )
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @rooms = Hash.new
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:rooms] = @rooms
    @connections[:clients] = @clients
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        nick_name = client.gets.chomp.to_sym
        @connections[:clients].each do |other_name, other_client|
          if nick_name == other_name || client == other_client
            client.puts "This username already exists"
            Thread.kill self
          end
        end
        puts "#{nick_name} (#{client}) has connected to the server."
        @connections[:clients][nick_name] = client
        client.puts "Connection established to server. Waiting for intructions..."
        listen_user_messages( nick_name, client )
      end
    }.join
  end

  def listen_user_messages( username, client )
    loop {
      msg = client.gets.chomp
      @connections[:clients].each do |other_name, other_client|
      puts "#{username.to_s}: #{msg}"
      end
    }
  end
end

# create queue variable
$renderqueue = Array.new

# create scenes folder
unless File.directory? 'scenes'
FileUtils.mkdir_p 'scenes'
puts "Created 'scenes' folder."
end
unless File.directory? 'scenes/done'
FileUtils.mkdir_p 'scenes/done'
puts "Created 'scenes/done' folder."
end

# make a config
def makeconfig
  puts "test"
end

# Startup Credits!
puts
puts "DistChunky Server vX.X.X"
puts "Written by colebob9"
puts "Released under the MIT licence"
puts "GitHub: <link>"
puts

# check for startup files
configexist = File.exist?('config.txt')
unless configexist
  makeconfig
else
  puts "config exists."
end
# start up the server

thread1 = Thread.new { Server.new( 3000, "localhost" ) }
thread1.run

# command interpreter
commands = Thread.new do
  loop do
    print "> "
    command = gets.chomp
    if command == "help"
      puts
      puts "Commands:"
      puts "'help' - Shows this screen"
      puts "'queue' - Lists what is in the render queue."
      puts "'queue help' - Lists all queue commands."
      puts "'exit' - Exits the program"
    elsif command == "queue"
      if $renderqueue.empty?
        puts "No scenes queued."
      else
        puts "Scenes:"
        puts $renderqueue
      end
    elsif command == "queue add"
      puts "What is the scene name?"
      print "? "
      addedscene = gets.chomp
      $renderqueue.push(addedscene)
      puts "Added scene: #{addedscene}"
    elsif command == "queue refresh"
      puts "placeholder"
    elsif command == "queue help"
      puts "Queue commands:"
      puts "'queue' - Lists what is in the render queue."
      puts "'queue add' - Adds a scene to the queue."
      puts "'queue refresh' - Searches for new scenes in queue folder."
    elsif command == "exit"
      exit
    else
      puts "Sorry, I don't know that command."
    end
    end
end
commands.join