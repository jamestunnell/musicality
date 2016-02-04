module Musicality
module Tasks

class Auditions < Rake::TaskLib
  attr_reader :auditions_dirs

  TEMPO_SAMPLE_RATE = 200
  AUDITIONS_DIR = "auditions"
  AUDITIONS_EXT = ".auditions"

  def initialize score_filelist, yaml_filelist, audio_format = nil
    auditions_filelist = score_filelist.ext(AUDITIONS_EXT).select {|f| File.exist?(f)}

    subdirs = auditions_filelist.pathmap("#{Project::OUT_DIR}/%n")
    @auditions_dirs = auditions_filelist.pathmap("#{Project::OUT_DIR}/%n/#{AUDITIONS_DIR}")

    directory Project::OUT_DIR
    subdirs.each { |subdir| directory subdir }
    @auditions_dirs.each { |auditions_dir| directory auditions_dir }

    format_flag = audio_format.nil? ? "" : "--format=#{audio_format}"
    subtask = audio_format.nil? ? "" : ":#{audio_format}"

    task "auditions#{subtask}" => [Project::OUT_DIR] + subdirs + yaml_filelist + @auditions_dirs do
      yaml_filelist.each_with_index do |yaml_fname,i|
        audition_fname = auditions_filelist[i]
        auditions_dir = @auditions_dirs[i]
        `auditions #{audition_fname} #{yaml_fname} --outdir="#{auditions_dir}" #{format_flag}`
      end
    end
  end

  class FLAC < Auditions
    def initialize score_filelist, yaml_filelist
      super(score_filelist, yaml_filelist, "flac")
    end
  end

  class WAV < Auditions
    def initialize score_filelist, yaml_filelist
      super(score_filelist, yaml_filelist, "wav")
    end
  end

  class AIFF < Auditions
    def initialize score_filelist, yaml_filelist
      super(score_filelist, yaml_filelist, "aiff")
    end
  end
end

end
end
