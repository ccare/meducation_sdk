module MeducationSDK
  class MeducationSDKError < StandardError
  end
  class MeducationSDKConfigurationError < MeducationSDKError
  end

  class Configuration

    SETTINGS = [
      :logger, :access_id, :secret_key, :endpoint
    ]

    attr_writer *SETTINGS

    def initialize
      Filum.config do |config|
        config.logfile = "./log/loquor.log"
      end
      logger = Filum.logger
    end

    SETTINGS.each do |setting|
      define_method setting do
        get_or_raise(setting)
      end
    end

    private

    def get_or_raise(setting)
      instance_variable_get("@#{setting.to_s}") ||
        raise(MeducationSDKConfigurationError.new("Configuration for #{setting} is not set"))
    end
  end
end
