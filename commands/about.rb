module TeBot
  class About
    def self.invoke
      "I am TE-BOT, ruler of all."
    end
  end
end

TeBot::IRCBot.register_command("about", TeBot::About)