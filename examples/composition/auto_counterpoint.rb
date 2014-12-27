require 'musicality'
include Musicality
include Pitches

durs_w_probs = { 1/8.to_r => 0.25, 1/4.to_r => 0.5, 1/2.to_r => 0.25 }
#durs_w_probs = { 1/6.to_r => 0.25, 1/4.to_r => 0.25, 1/3.to_r => 0.25, 1/12.to_r => 0.25 }
rrg = RandomRhythmGenerator.new(durs_w_probs)
palette = durs_w_probs.keys

bass_pitches = [ C2, D2, F2, E2, A2, E2, D2 ]
guitar_pitches = [ F3, F3, A3, G3, C4, A3, G3 ]

bass = Part.new(Dynamics::MF)
guitar = Part.new(Dynamics::MF)

25.times do
  rhythm = rrg.random_rhythm(1)
  
  cpg = CounterpointGenerator.new(rhythm,palette)
  counterpoint = cpg.best_solution(1/12.to_r)
  
  bass.notes += make_notes(counterpoint, bass_pitches)
  guitar.notes += make_notes(rhythm, guitar_pitches)
end

score = Score::Unmeasured.new(120,
  parts: { "bass" => bass, "guitar" => guitar },
  program: [ 0...([bass.duration,guitar.duration].min) ]
)

instr_map = { "bass" => 32, "guitar" => 25 }
seq = ScoreSequencer.new(score.to_timed(200)).make_midi_seq(instr_map)
File.open("./auto_counterpoint.mid", 'wb'){ |fout| seq.write(fout) }