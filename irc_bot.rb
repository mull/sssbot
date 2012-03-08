require_relative 'irc_connection'
#require_relative 'irc_commands'

module TeBot
  class IRCBot < TeBot::IRCConnection
    @@commands = {}
  
    def initialize(server, port, nick, channel)
      super
    end
  
    def handle_input(s)
      super
    end
  
    def self.register_command(command_name, klass)
      @@commands[command_name] = klass
    end
    
    def handle_privmsg(user, channel, message)
      # Command invoked?
      if message[0] == '.'
        command = message[1..-1]
        if !command_for?(command).nil?
          ret_msg = invoke_command(command)
          puts ret_msg
          send_to(channel, "#{user}: #{ret_msg}")
        end
      end
    end
    
    def invoke_command(command_name)
      klass = @@commands[command_name]
      klass.invoke
    end
    
    private
    
    def command_for?(message)
      return true if @@commands[message]
    end
  end
end

# Load all commands
Dir[File.dirname(__FILE__) + '/commands/*.rb'].each do |file| 
  require_relative 'commands/' + File.basename(file, File.extname(file))
end




# The main loop
# Just keep going if we get an error 8)
#bot = TeBot::IRCBot.new('irc.freenode.org', 6667, 'te-botjvl', '#mull-devving')
bot = TeBot::IRCBot.new('irc.quakenet.org', 6667, 'te-botjvl', '#theencounter.nu')

begin
  bot.main_loop()
rescue Interrupt
rescue Exception => detail
  puts detail.message()
  print detail.backtrace.join("\n")
  retry
end
bot.exit