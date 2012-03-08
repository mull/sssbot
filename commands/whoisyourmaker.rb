module TeBot
  class WhoIsYourMaker
    def self.invoke
      "eml! :3"
    end
  end
end

TeBot::IRCBot.register_command("whoisyourmaker", TeBot::WhoIsYourMaker)