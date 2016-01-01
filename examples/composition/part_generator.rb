require 'musicality'
include Musicality
include Pitches
include PitchClasses
include Meters
include ScaleClasses

minor = Heptatonic::Prima::MINOR
major = Heptatonic::Prima::MAJOR

pitch_seqs = {
  D4 => minor, C4 => major, E4 => minor, F4 => minor
}.map do |pitch,scale_class|
  scale_class.to_pitch_seq(pitch)        
end

rhythm_seq2 = RepeatingSequence.new([3/8.to_r]*4)

score = Score::Tempo.new(SIX_EIGHT,90) do |s|
  s.parts["main"] = Part.new(Dynamics::MF) do |p|
    p.settings.push MidiSettings::LEAD_SAWTOOTH

    rhythm_seq = RepeatingSequence.new(([1/8.to_r]*3)*3 + [1/4.to_r,1/8.to_r])
    selector = RepeatingSequence.new([4,2,0])
    rhythm = rhythm_seq.take(pitch_seqs.size * rhythm_seq.pattern_size).to_a
    poffsets = selector.take(rhythm_seq.pattern_size).to_a
    pitches = pitch_seqs.map { |pseq| pseq.at(poffsets).to_a }.flatten
    p.notes += make_notes(rhythm,pitches)
  end
  
  s.parts["bass"] = Part.new(Dynamics::MP) do |p|
    p.settings.push MidiSettings::LEAD_SQUARE

    rhythm_seq = RepeatingSequence.new([3/8.to_r]*4)
    selector = RepeatingSequence.new([-7])
    rhythm = rhythm_seq.take(pitch_seqs.size * rhythm_seq.pattern_size).to_a
    poffsets = selector.take(rhythm_seq.pattern_size).to_a
    pitches = pitch_seqs.map { |pseq| pseq.at(poffsets).to_a }.flatten
    p.notes += make_notes(rhythm,pitches)
  end
  
  s.parts["pluck"] = Part.new(Dynamics::MP) do |p|
    p.settings.push MidiSettings::ORCHESTRAL_HARP

    rhythm_seq = RepeatingSequence.new(([1/8.to_r]*3)*4)
    selector = RepeatingSequence.new([0,2,4])
    rhythm = rhythm_seq.take(pitch_seqs.size * rhythm_seq.pattern_size).to_a
    poffsets = selector.take(rhythm_seq.pattern_size).to_a
    pitches = pitch_seqs.map { |pseq| pseq.at(poffsets).to_a }.flatten
    p.notes += make_notes(rhythm,pitches)
  end
  
  s.program = [0...s.measures_long]*2
end

seq = ScoreSequencer.new(score.to_timed(200)).make_midi_seq
File.open("./part_generator.mid", 'wb'){ |fout| seq.write(fout) }