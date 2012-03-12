require_relative 'irc_connection'

module TeBot
  class IRCBot < TeBot::IRCConnection
    @@commands = {}
    @@plugins = {}
  
    def initialize(server, port, nick, channel)
      super
    end
  
    def handle_input(s)
      super
    end
  
    def self.register_command(command_name, klass)
      @@commands[command_name] = klass
    end
    
    def add_plugin(plugin_name)
      require_relative "plugins/#{plugin_name}.rb"
      klass_name = ""
      plugin_name.split("_").each do |p|
        klass_name += p.capitalize
      end
      
      klass = Object.const_get(klass_name)
      @@plugins[plugin_name] = klass
    end
    
    def fire_plugins
      @@plugins.each do |name, klass|
        puts "Firing #{name}"
        @@plugins[name] = klass.new(self)
      end
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
    
    def handle_input(s)
      case s.strip
        when /:(.+) PRIVMSG (#.+) :(.+)$/i
          user = $1
          channel = $2
          message = $3
          user = user.match(/(.+)!/)[1]
          handle_privmsg(user, channel, message)
        
        when /:#{@nick}!~...* JOIN (#.+)/i
          fire_plugins
      end
      super
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

# Load all plugins
#Dir[File.dirname(__FILE__) + '/plugins/*.rb'].each do |file|
#  require_relative 'plugins/' + File.basename(file, File.extname(file))
#end



# The main loop
# Just keep going if we get an error 8)
bot = TeBot::IRCBot.new('irc.freenode.org', 6667, 'te-botjvl', '#mull-devving')
#bot = TeBot::IRCBot.new('irc.quakenet.org', 6667, 'te-botjvl', '#theencounter.nu')


#TeBot::IRCBot.send_to("lol", "lol")

begin
  bot.add_plugin('news_fetcher')
  bot.main_loop()
rescue Interrupt
rescue Exception => detail
  puts detail.message()
  print detail.backtrace.join("\n")
  retry
end
bot.exit