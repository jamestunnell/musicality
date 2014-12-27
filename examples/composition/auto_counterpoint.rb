require 'musicality'
include Musicality

durs_w_probs = { 1/8.to_r => 0.25, 1/4.to_r => 0.5, 1/2.to_r => 0.25 }
rrg = RandomRhythmGenerator.new(durs_w_probs)
palette = durs_w_probs.keys

bass_pitch = Pitches::C2
guitar_pitch = Pitches::F3 # MidiUtil.notenum_to_pitch(38)

bass = Part.new(Dynamics::MF)
guitar = Part.new(Dynamics::MF)

25.times do
  rhythm = rrg.random_rhythm(1)
  cpg = CounterpointGenerator.new(rhythm,palette)
  counterpoint = cpg.best_solution(1/8.to_r)
  
  bass.notes += make_notes(rhythm, [bass_pitch])
  guitar.notes += make_notes(counterpoint, [guitar_pitch])
end

score = Score::Unmeasured.new(120,
  parts: { "bass" => bass, "guitar" => guitar },
  program: [ 0...bass.duration ]
)

instr_map = { "bass" => 32, "guitar" => 25 }
seq = ScoreSequencer.new(score.to_timed(200)).make_midi_seq(instr_map)
File.open("./auto_counterpoint.mid", 'wb'){ |fout| seq.write(fout) }