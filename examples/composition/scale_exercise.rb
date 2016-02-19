require 'musicality'
include Musicality
include Pitches
include Meters
include ScaleClasses

def scale_exercise scale_class, base_pitch, rhythm
  scale = scale_class.to_pitch_seq(base_pitch)
  n = scale_class.count
  m = rhythm.size

  rseq = RepeatingSequence.new((0...m).to_a)
  aseq = AddingSequence.new([0]*(m-1) + [1])
  cseq = CompoundSequence.new(:+,[aseq,rseq])
  pgs = cseq.take(m*n).map {|i| scale.at(i) }
  notes = make_notes(rhythm, pgs) +
          make_notes([3/4.to_r,-1/4.to_r], [scale.at(n)])

  rseq = RepeatingSequence.new(n.downto(n+1-m).to_a)
  aseq = AddingSequence.new([0]*(m-1) + [-1])
  cseq = CompoundSequence.new(:+,[aseq,rseq])
  pgs = cseq.take(m*n).map {|i| scale.at(i) }
  notes += make_notes(rhythm, pgs) +
          make_notes([3/4.to_r,-1/4.to_r], [scale.at(0)])

  return notes
end

score = Score::Tempo.new(120) do |s|
  s.parts["scale"] = Part.new(Dynamics::MP) do |p|
    Heptatonic::Prima::MODES.each do |mode_n,scale_class|
      [[1/4.to_r,1/4.to_r,1/2.to_r]].each  do |rhythm|
        p.notes += scale_exercise(scale_class, C3, rhythm)
      end
    end
  end
  s.program.push 0...s.measures_long
end

seq = ScoreSequencer.new(score.to_timed(200)).make_midi_seq("scale" => 1)
File.open("./scale_exercise.mid", 'wb'){ |fout| seq.write(fout) }
