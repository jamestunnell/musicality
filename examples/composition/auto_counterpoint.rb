require 'musicality'
include Musicality
include Pitches

bass_pitch_palette = [ C2, D2, E2, F2, G2, A2, B2, C3 ]
guitar_pitch_palette = [ C3, D3, E3, F3, G3, A3, B3, C4 ]

bass = Part.new(Dynamics::MF, settings: [MidiSettings::ELECTRIC_BASS_FINGER])
guitar = Part.new(Dynamics::MF, settings: [MidiSettings::ELECTRIC_GUITAR_JAZZ])

def random_melody rhythm, pitch_palette
  pitches = pitch_palette.sample(rand(2..pitch_palette.size))
  pitch_sampler = RandomSampler.new(pitches,Probabilities.random(pitches.size))
  make_notes(rhythm, pitch_sampler.sample(rhythm.size))
end
  
def random_counterpoint rhythm, rhythm_palette, sample_rate, pitch_palette
  cpg = CounterpointGenerator.new(rhythm,rhythm_palette)
  counterpoint = cpg.best_solutions(25,0.5,sample_rate).sample
  pitches = pitch_palette.sample(rand(2..pitch_palette.size))
  pitch_sampler = RandomSampler.new(pitches,Probabilities.random(pitches.size))
  make_notes(counterpoint, pitch_sampler.sample(counterpoint.size))  
end

2.times do
  [ {
      :rhythm_probs => { 1/8.to_r => 0.25, 1/4.to_r => 0.25, 1/6.to_r => 0.25, 1/2.to_r => 0.25 },
      :sample_rate => 48,
    },
    {
      :rhythm_probs => { 1/8.to_r => 0.325, 1/4.to_r => 0.325, 3/16.to_r => 0.10, 1/2.to_r => 0.25 },
      :sample_rate => 16,
    },
  ].each do |params|
    rrg =RandomRhythmGenerator.new(params[:rhythm_probs])
    rhythm_palette = params[:rhythm_probs].keys
    5.times do
      rhythm = rrg.random_rhythm(3/4.to_r)
      guitar.notes += random_melody(rhythm, guitar_pitch_palette)
      bass.notes += random_counterpoint(rhythm, rhythm_palette,
                                        params[:sample_rate], bass_pitch_palette)
    end
  end
end

score = Score::Tempo.new(Meters::FOUR_FOUR, 120,
  parts: { "bass" => bass, "guitar" => guitar },
  program: [ 0...([bass.duration,guitar.duration].min) ]
)

seq = ScoreSequencer.new(score.to_timed(200)).make_midi_seq
File.open("./auto_counterpoint.mid", 'wb'){ |fout| seq.write(fout) }