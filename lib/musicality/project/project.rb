module Musicality

class Project
  USEFUL_MODULES = ['Musicality','Pitches','Meters','Keys','Articulations','Dynamics']

  attr_reader :dest_dir
  def initialize dest_dir
    @dest_dir = dest_dir

    create_project_dir
    create_gemfile
    create_rakefile
    create_config
    create_scores_dir
  end

  def create_project_dir
    if Dir.exists? dest_dir
      unless Dir.glob(File.join(dest_dir,"*")).empty?
        raise ArgumentError, "existing directory #{dest_dir} is not empty."
      end
    else
      Dir.mkdir(dest_dir)
      unless Dir.exists?(dest_dir)
        raise "directory #{dest_dir} could not be created"
      end
    end    
  end

  def create_gemfile
    gemfile_path = File.join(dest_dir,"Gemfile")
    File.open(gemfile_path,"w") do |f|
      f.puts("source :rubygems")
      f.puts("gem 'musicality', '~> #{VERSION}'")
    end
  end

  def create_rakefile
    rakefile_path = File.join(dest_dir,"Rakefile")
    File.open(rakefile_path,"w") do |f|
      f.puts("require 'musicality'")
      USEFUL_MODULES.each do |module_name|
        f.puts("include #{module_name}")
      end
      f.puts
      f.puts("config = Project.load_config(File.dirname(__FILE__))")
      f.puts("Project.create_tasks(config)")
    end
  end

  def create_config
    config_path = File.join(dest_dir, Project::CONFIG_FILE_NAME)
    File.open(config_path,"w") do |f|
      f.write(Project::DEFAULT_CONFIG.to_yaml)
    end
  end

  def create_scores_dir
    scores_dir = File.join(dest_dir, Project::DEFAULT_CONFIG[:scores_dir])
    Dir.mkdir(scores_dir)
  end
end

end