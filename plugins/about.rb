class About < TeBot::Plugin
  def self.hooks
    [:command]
  end
  
  def command(user, channel, message)
    if message == ".about"
      @bot_instance.send_to(channel, "#{user}: I am te-bot, motherfcking ruler of all!")
    end
  end
end