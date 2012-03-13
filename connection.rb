require "socket"

module S3Bot
  class Connection
    def initialize(server, port, nick, channels)
      @server = server
      @port = port
      @nick = nick
      @ident = "USER #{(@nick+" ")*3}:#{(@nick+" ")*2}"
      @channels = {
        :list => [],
        :nicks => {},
        :joined => {}
      }
      
      if !channels.is_a?(Array)
        @channels[:list] << channels
      else
        @channels[:list] = channels
      end
    end
  
    def connect
      @irc = TCPSocket.open(@server, @port)
      send "NICK #{@nick}"
      send @ident
      join_channels(@channels[:list])
    end
  
    def send(s)
      puts "--> #{s}"
      @irc.send "#{s}\n", 0
    end
    
    def send_to(channel, message)
      channel = "##{channel}" if channel[0] != '#'
      send("PRIVMSG #{channel} :#{message}")
    end
  
    def handle_input(s)
      puts s
      
      # Handle input and respond to PINGs etc
      case s.strip
        when /^PING (:.+)$/i
          puts "PING #{$1}"
          send "PONG #{$1}"
          
        when /(...)Register first./ # QuakeNET -.-
          send @ident
          join_channels(@channels[:list])
          
        when /:* (353) te-botjvl @ (#.*) :(.+)/
          # Channel nick list
          channel = $2
          nicks = $3
          joined_channel($2, $3)
      end
    end
    
    def handle_privmsg(user, channel, message)
    end
    
    def channels
      @channels
    end
  
    def main_loop
      connect
      while true
        ready = select([@irc, $stdin])
        next if !ready
      
        handle_input(@irc.gets)
      end
    end
  
    def exit
      @irc.close
    end
    
    private
    
    def joined_channel(channel, nicks)
      @channels[:nicks][channel] ||= []
      nicks.split(" ").each do |nick|
        @channels[:nicks][channel] << nick
      end
    end
    
    def join_channels(channels)
      if channels.is_a?(Array)
        channels.each do |channel|
          send "JOIN #{channel}"
        end
      end
    end
  end
end