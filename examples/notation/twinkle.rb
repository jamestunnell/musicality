require 'musicality'
include Musicality
include Meters
include Dynamics
include Pitches

score = Score::Tempo.new(FOUR_FOUR, 120, title: "Twinkle, Twinkle, Little Star") do |s|
  s.parts["rhand"] = Part.new(MF) do |p|
    a_notes = q(C4,C4,G4,G4,A4,A4) + h(G4) +
              q(F4,F4,E4,E4,D4,D4) + h(C4)
    b_notes = q(G4,G4,F4,F4,E4,E4) + h(D4)
    p.notes += a_notes + b_notes
  end
  
  s.parts["lhand"] = Part.new(MF) do |p|
    Cmaj = [C3,E3,G3]
    Fmaj = [F2,A2,C3]
    Gmaj = [G2,B2,D3]
    
    a_chords = h(Cmaj,Cmaj,Fmaj,Cmaj) + 
               h(Fmaj,Cmaj,Gmaj,Cmaj)
    b_chords = h(Cmaj,Fmaj,Cmaj,Gmaj)
    p.notes += a_chords + b_chords
  end
  
  s.program.push 0...4
  s.program.push 0...2
  s.program.push 0...2
  s.program.push 0...4
end

File.open('twinkle.ly','w'){|f| f.write(score.to_lilypond) }
File.open('twinkle.mid','wb'){|f| score.to_midi_seq(200).write(f) }