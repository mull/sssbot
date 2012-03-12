require_relative 'irc_connection'
require_relative 'bot_plugin'

module TeBot
  class IRCBot < TeBot::IRCConnection
    @@plugins = {}
    
    def initialize(server, port, nick, channel)
      @plugin_hooks = {
        :command => []
      }
      super
    end
  
    def handle_input(s)
      super
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
        @@plugins[name] = klass.new(self)
        plugin_hooks = klass.hooks
        plugin_hooks.each do |hook|
          @plugin_hooks[hook] ||= []
          @plugin_hooks[hook] << name
        end
      end
    end 
    
    def handle_privmsg(user, channel, message)
      # Command invoked?
      if message[0] == '.'
        @plugin_hooks[:command].each do |plugin_name|
          puts @@plugins[plugin_name]
          @@plugins[plugin_name].command(user, channel, message)
        end
      end
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
  end
end

# The main loop
# Just keep going if we get an error 8)
bot = TeBot::IRCBot.new('irc.freenode.org', 6667, 'te-botjvl', '#mull-devving')
#bot = TeBot::IRCBot.new('irc.quakenet.org', 6667, 'te-botjvl', '#theencounter.nu')

# Load all plugins
Dir[File.dirname(__FILE__) + '/plugins/*.rb'].each do |file|
  bot.add_plugin(File.basename(file, File.extname(file)))
end

begin
  bot.main_loop()
rescue Interrupt
rescue Exception => detail
  puts detail.message()
  print detail.backtrace.join("\n")
  retry
end
bot.exit