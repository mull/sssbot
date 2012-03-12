class TeBot::Plugin
  def initialize(bot_instance)
    @bot_instance = bot_instance
  end
  
  def self.hooks
    []
  end
end