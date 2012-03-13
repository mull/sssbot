module S3Bot
  class Plugin
    def initialize(bot_instance)
      @bot_instance = bot_instance
    end

    def self.hooks
      []
    end
  end
end