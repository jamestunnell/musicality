module Musicality
module Project

class FileRaker < Rake::TaskLib
  attr_reader :files, :task_name, :file_ext
  
  def initialize parent_filelist, task_name, file_ext, &rule_block
    raise ArgumentError, "parent filelist is empty" if parent_filelist.empty?
    raise ArgumentError, "no rule block given" unless block_given?
    
    @task_name, @file_ext = task_name, file_ext
    @files = parent_filelist.ext(file_ext)
    
    task task_name => @files
    
    parent_exts = parent_filelist.map {|str| File.extname(str) }.uniq
    raise ArgumentError, "multiple file extensions in parent filelist: #{parent_filelist}" unless parent_exts.one?
    parent_ext = parent_exts.first
    
    rule file_ext => parent_ext do |t|
      rule_block.call(t)
    end
  end
  
  class YAML < FileRaker
    def initialize score_files
      super(score_files, :yaml, ".yml") do |t|
        puts "#{t.source} -> #{t.name}"
        yml = ScoreDSL.load(t.source).score.pack.to_yaml
        File.write(t.name, yml)
      end
    end
  end
  
  class LilyPond < FileRaker
    def initialize yaml_files
      super(yaml_files, :lilypond, ".ly") do |t|
        sh "lilify \"#{t.sources[0]}\""
      end
    end
  end
  
  class MIDI < FileRaker
    def initialize yaml_files, tempo_sample_rate
      super(yaml_files, :midi, ".mid") do |t|
        sh "midify \"#{t.sources[0]}\" --srate=#{tempo_sample_rate}"
      end
    end
  end
  
  class SuperCollider < FileRaker
    def initialize yaml_files, tempo_sample_rate
      super(yaml_files, :supercollider, ".osc") do |t|
        sh "collidify \"#{t.sources[0]}\" --srate=#{tempo_sample_rate}"
      end
    end
  end
  
  class Audio < FileRaker
    def check_sample_format audio_file_type, sample_format
      combination_okay = case audio_file_type
      when :wav
        sample_format != "int8"
      when :flac
        !["int32","float","mulaw","alaw"].include?(sample_format)
      else
        true  
      end

      unless combination_okay
        raise ConfigError, "#{audio_file_type} file format can not be used with #{sample_format} sample format"
      end
    end

    def initialize osc_files, audio_file_type, sample_rate, sample_format
      super(osc_files, audio_file_type, ".#{audio_file_type}") do |t|
        check_sample_format audio_file_type, sample_format

        osc_fpath = t.sources[0]
        out_fpath = File.join(File.dirname(osc_fpath), File.basename(osc_fpath, File.extname(osc_fpath)) + ".#{audio_file_type}")
        
        cmd_line = "scsynth -N \"#{osc_fpath}\" _ \"#{out_fpath}\" #{sample_rate} #{audio_file_type} #{sample_format}"
        IO.popen(cmd_line) do |pipe|
          while response = pipe.gets
            puts response
            if /Couldn't open non real time command file/ =~ response
              puts "The #{sample_format} sample format is not compatible with file format"
              File.delete(out_fpath)
              break
            end
          end
        end
      end
    end
  end
  
  class Visual < FileRaker
    def initialize lilypond_files, visual_file_type
      super(lilypond_files, visual_file_type, ".#{visual_file_type}") do |t|
        sh "lilypond #{t.sources[0]} --#{visual_file_type}"
      end
    end
  end
end

end
end