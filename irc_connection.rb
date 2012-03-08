require "socket"

module TeBot
  class IRCConnection
    def initialize(server, port, nick, channel)
      @server = server
      @port = port
      @nick = nick
      @channel = channel
      @ident = "USER te-bot te-bot te-bot :tebot tebot"
    end
  
    def connect
      @irc = TCPSocket.open(@server, @port)
      send "NICK #{@nick}"
      send @ident
      send "JOIN #{@channel}"
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
          
        when /(...)Register first./
          send @ident
          send "JOIN #{@channel}"
          
        when
          /:(.+) PRIVMSG (#.+) :(.+)$/i
          user = $1
          channel = $2
          message = $3
          user = user.match(/(.+)!/)[1]
          handle_privmsg(user, channel, message)

      end
    end
    
    def handle_privmsg(user, channel, message)
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
  end
end