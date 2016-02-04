module Musicality

class Project
  CONFIG_FILE_NAME = "config.yml"
  SCORES_DIR = "scores"
  SCORE_EXT = ".score"
  OUT_DIR = "output"
  SAMPLE_FORMATS = ["int8", "int16", "int24", "int32", "mulaw", "alaw", "float"]
  DEFAULT_CONFIG = {
    :tempo_sample_rate => 200,
    :audio_sample_rate => 44100,
    :audio_sample_format => "int16"
  }
  GEM_MUSICALITY = "gem 'musicality', '~> #{VERSION}'"
  USEFUL_MODULES = ['Musicality','Pitches','Meters','Keys','Articulations','Dynamics']

  class ConfigError < RuntimeError
  end

  def initialize dest_dir
    Project.create_project_dir_if_needed(dest_dir)
    Project.create_scores_dir_if_needed(dest_dir)
    Project.update(dest_dir)
  end

  def self.update dest_dir
    if File.exists?(gemfile_path(dest_dir))
      puts "Updating Gemfile"
      update_gemfile(dest_dir)
    else
      puts "Creating Gemfile"
      create_gemfile(dest_dir)
    end

    if File.exists?(rakefile_path(dest_dir))
      puts "Updating Rakefile"
      update_rakefile(dest_dir)
    else
      puts "Creating Rakefile"
      create_rakefile(dest_dir)
    end

    if File.exists?(config_path(dest_dir))
      puts "Updating config.yml"
      update_config(dest_dir)
    else
      puts "Creating config.yml"
      create_config(dest_dir)
    end
  end

  def self.config_path(dest_dir)
    File.join(dest_dir,"config.yml")
  end

  def self.gemfile_path(dest_dir)
    File.join(dest_dir,"Gemfile")
  end

  def self.rakefile_path(dest_dir)
    File.join(dest_dir,"Rakefile")
  end

  def self.create_project_dir_if_needed(dest_dir)
    if Dir.exists?(dest_dir)
      puts "Project directory already exists"
    else
      puts "Creating project directory #{dest_dir}"
      Dir.mkdir(dest_dir)
      unless Dir.exists?(dest_dir)
        raise "directory #{dest_dir} could not be created"
      end
    end
  end

  def self.create_scores_dir_if_needed(dest_dir, scores_dir = Project::SCORES_DIR)
    scores_dir = File.join(dest_dir, scores_dir)
    if Dir.exists? scores_dir
      puts "Scores directory already exists"
    else
      puts "Creating scores directory #{scores_dir}"
      Dir.mkdir(scores_dir)
      unless Dir.exists?(scores_dir)
        raise "directory #{scores_dir} could not be created"
      end
    end
  end

  #
  # Gemfile
  #

  def self.create_gemfile(dest_dir)
    gemfile_path = File.join(dest_dir,"Gemfile")
    File.new(gemfile_path(dest_dir),"w")
    update_gemfile(dest_dir)
  end

  def self.update_gemfile(dest_dir)
    pre_lines = []
    lines = File.readlines(gemfile_path(dest_dir)).map {|l| l.chomp }

    if line = lines.find {|x| x =~ /source/ }
      delete_empty_lines_around lines, line
      pre_lines.push lines.delete(line)
    else
      pre_lines.push("source :rubygems")
    end

    if line = lines.find {|x| x =~ /gem/ && x =~ /musicality/ }
      delete_empty_lines_around lines, line
      lines.delete(line)
    end
    pre_lines.push GEM_MUSICALITY

    File.open(gemfile_path(dest_dir),"w") do |f|
      f.puts pre_lines
      if lines.any?
        f.puts [""] + lines
      end
    end
  end

  #
  # Rakefile
  #

  def self.create_rakefile(dest_dir)
    rakefile_path = File.join(dest_dir,"Rakefile")
    File.new(rakefile_path(dest_dir),"w")
    update_rakefile(dest_dir)
  end

  def self.update_rakefile(dest_dir)
    pre_lines = []
    lines = File.readlines(rakefile_path(dest_dir)).map {|l| l.chomp }

    if line = lines.find {|x| x =~ /^[\s]*require[\s]+[\'\"]musicality[\'\"]/}
      delete_empty_lines_around lines, line
      pre_lines.push lines.delete(line)
    else
      pre_lines.push "require 'musicality'"
    end
    pre_lines.push ""

    USEFUL_MODULES.each do |module_name|
      if line = lines.find {|x| x =~ /^[\s]*include[\s]+#{module_name}/}
        delete_empty_lines_around lines, line
        pre_lines.push lines.delete(line)
      else
        pre_lines.push "include #{module_name}"
      end
    end

    pre_lines.push ""
    if line = lines.find {|x| x =~ /Project\.load_config/ }
      delete_empty_lines_around lines, line
      pre_lines.push lines.delete(line)
    else
      pre_lines.push "config = Project.load_config(File.dirname(__FILE__))"
    end

    if line = lines.find {|x| x =~ /Project\.create_tasks/ }
      delete_empty_lines_around lines, line
      pre_lines.push lines.delete(line)
    else
      pre_lines.push "Project.create_tasks(config)"
    end

    File.open(rakefile_path(dest_dir),"w") do |f|
      f.puts pre_lines
      if lines.any?
        f.puts [""] + lines
      end
    end
  end

  #
  # config.yml
  #

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

  def self.create_config(dest_dir, config = Project::DEFAULT_CONFIG)
    File.open(config_path(dest_dir),"w") do |f|
      f.write(config.to_yaml)
    end
  end

  def self.update_config(dest_dir)
    config = Project.load_config(dest_dir)
    config = Project::DEFAULT_CONFIG.merge(config)
    create_config(dest_dir, config)
  end

  private

  def self.delete_empty_lines_around lines, line
    # delete lines before
    i = lines.index(line)-1
    while (i >= 0) && lines[i].empty?
      lines.delete_at i
      i -= 1
    end

    # delete lines after
    i = lines.index(line)+1
    while (i < lines.size) && lines[i].empty?
      lines.delete_at i
    end
  end
end

end
