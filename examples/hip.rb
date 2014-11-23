require 'musicality'
require 'yaml'

include Musicality
include Pitches
include Articulations
include Meters

score = Score::Measured.new(FOUR_FOUR,120) do |s|
  s.program = Program.new([0...2, 0...2,2...4,0...2])
  s.parts["lead"] = Part.new(Dynamics::MF) do |p|
    riff = "/6Bb3 /4 /12Db4= /6Db4= /36Db4 /36Eb4 /36Db4 /6Ab3 /12Db4 \
            /6Bb3 /4 /12Db4= /4Db4=                      /8=Db4 /8C4".to_notes
    p.notes = riff + riff.map {|n| n.transpose(2) }
  end
  
  s.parts["bass"] = Part.new(Dynamics::MP) do |p|
    riff = "/6Bb2 /4 /3Ab2 /6F2 /12Ab2 \
            /6Bb2 /4 /3Ab2 /4Ab2".to_notes
    p.notes = riff + riff.map {|n| n.transpose(2) }
  end
end

name = File.basename(__FILE__,".rb")

File.open("#{name}.yml", "w") do |file|
  file.write score.to_yaml
end

File.open("#{name}_packed.yml", "w") do |file|
  file.write score.pack.to_yaml
end
