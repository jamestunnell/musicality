module Musicality

class Project
  CONFIG_FILE_NAME = "config.yml"
  BASE_SCORES_DIR = "scores"

  DEFAULT_CONFIG = {
    :scores => File.join(BASE_SCORES_DIR, "**", "*.score"),
    :tempo_sample_rate => 200,
    :audio_sample_rate => 44100, 
    :audio_sample_format => "int16"
  }

  SAMPLE_FORMATS = ["int8", "int16", "int24", "int32", "mulaw", "alaw", "float"]

  class ConfigError < RuntimeError
  end

  def self.check_config config
    config.each do |k,v|
      case k
      when :audio_sample_format
        raise ConfigError, "#{k} => #{v} is not allowed" unless SAMPLE_FORMATS.include?(v)
      when :tempo_sample_rate, :audio_sample_rate
        raise ConfigError, "#{k} => #{v} is not positive" unless v > 0
      end
    end
  end

  def self.load_config project_root_dir
    globabl_config_path = File.join(project_root_dir,CONFIG_FILE_NAME)
    
    config = if File.exists? globabl_config_path
      global_config = YAML.load(File.read(globabl_config_path))
      DEFAULT_CONFIG.merge global_config
    else
      DEFAULT_CONFIG
    end

    # overrides from ENV
    config.keys.each do |k|
      k_str = k.to_s
      if ENV.has_key? k_str
        case k
        when :tempo_sample_rate, :audio_sample_rate
          config[k] = ENV[k_str].to_i
        else
          config[k] = ENV[k_str]
        end
      end
    end

    check_config config
    return config
  end
end

end