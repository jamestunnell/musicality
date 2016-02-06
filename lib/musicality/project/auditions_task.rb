module Musicality
module Tasks

class Auditions < Rake::TaskLib
  attr_reader :auditions_dirs

  TEMPO_SAMPLE_RATE = 200
  AUDITIONS_DIR = "auditions"
  AUDITIONS_EXT = ".auditions"

  def initialize yaml_filelist, audio_format = nil
    @auditions_dirs = yaml_filelist.pathmap("%d/#{AUDITIONS_DIR}")
    @auditions_dirs.each { |auditions_dir| directory auditions_dir }

    format_flag = audio_format.nil? ? "" : "--format=#{audio_format}"
    subtask = audio_format.nil? ? "" : ":#{audio_format}"

    task "auditions#{subtask}" => yaml_filelist + @auditions_dirs do
      yaml_filelist.each_with_index do |yaml_fname,i|
        auditions_dir = @auditions_dirs[i]
        `auditions #{yaml_fname} --outdir="#{auditions_dir}" #{format_flag}`
      end
    end
  end
end

end
end
