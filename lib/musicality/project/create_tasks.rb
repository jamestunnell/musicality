module Musicality
module Project

def self.create_tasks config
  score_files = Rake::FileList[File.join(config[:scores_dir],"**/*.score")]
  
  yaml_task = FileRaker::YAML.new(score_files)
  
  tempo_sample_rate = config[:tempo_sample_rate]
  lilypond_task = FileRaker::LilyPond.new(yaml_task.files)
  midi_task = FileRaker::MIDI.new(yaml_task.files, tempo_sample_rate)
  supercollider_task = FileRaker::SuperCollider.new(yaml_task.files, tempo_sample_rate)
  
  sample_rate, sample_format = config[:audio_sample_rate], config[:audio_sample_format]
  wav_task = FileRaker::Audio.new(supercollider_task.files, :wav, sample_rate, sample_format)
  aiff_task = FileRaker::Audio.new(supercollider_task.files, :aiff, sample_rate, sample_format)
  flac_task = FileRaker::Audio.new(supercollider_task.files, :flac, sample_rate, sample_format)
  
  pdf_task = FileRaker::Visual.new(lilypond_task.files, :pdf)
  png_task = FileRaker::Visual.new(lilypond_task.files, :png)
  ps_task = FileRaker::Visual.new(lilypond_task.files, :ps)

  outfiles = (yaml_task.files + midi_task.files + supercollider_task.files + wav_task.files + aiff_task.files + flac_task.files + pdf_task.files + png_task.files + ps_task.files).select {|fname| File.exists? fname }
  clean_task = FileCleaner.new(outfiles)  
end

end
end
