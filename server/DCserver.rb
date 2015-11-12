#!/usr/bin/env ruby -w
puts "Loading..."

# load time tracker
def load_time(start, finish)
   finish - start
end
time1 = Time.now

# defining classes and methods first
require "socket"
require "FileUtils"
require "yaml"
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

# create config folder
unless File.directory? 'config'
FileUtils.mkdir_p 'config'
puts "Created 'config' folder."
end

# make config files
unless File.exist?('config/config.yml')
  puts "test for config code"
end

# writes everytime there is a change to the queue
def queuedump
  File.open("config/queue.yml", "w") do |file|
    file.write(YAML.dump($renderqueue))
  end
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
      puts "What is the scene name that you want to add?"
      puts "Put '@' if you want to cancel."
      print "? "
      addedscene = gets.chomp
      if addedscene == "@"
        puts "Canceled removal."
      else
        $renderqueue.push(addedscene)
        puts "Added scene: #{addedscene}"
      end
    elsif command == "queue remove"
      puts "What is the scene name that you want to remove?"
      puts "Put '@' if you want to cancel."
      print "? "
      removedscene = gets.chomp
      if removedscene == "@"
        puts "Canceled removal."
      else
        $renderqueue.delete(removedscene)
        puts "Added scene: #{removedscene}"
        queuedump
      end
    elsif command == "queue help"
      puts "Queue commands:"
      puts "'queue' - Lists what is in the render queue."
      puts "'queue add' - Adds a scene to the queue."
      puts "'queue remove' - Removes a scene from the queue."
    elsif command == "exit"
      exit
    else
      puts "Sorry, I don't know that command."
    end
    end
end
time2 = Time.now
time = load_time time1, time2
puts "Done loading! Took #{time} second(s)."
# Startup Credits!
puts
puts "DistChunky Server vX.X.X"
puts "Written by colebob9"
puts "Released under the MIT licence"
puts "GitHub: <link>"
puts
commands.join
