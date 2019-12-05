module Musicality

module ChordClasses
  MAJ = ChordClass.new [4,7]
  MAJ_6 = ChordClass.new [4,7,9]
  MAJ_6_9 = ChordClass.new [4,7,9,14]
  MAJ_7 = ChordClass.new [4,7,11]
  MAJ_9 = ChordClass.new [4,7,11,14]

  DIM = ChordClass.new [3,6]
  DOM_7 = ChordClass.new [4,7,10]
  DOM_7_SHARP_5 = ChordClass.new [4,8,10]
  DOM_9 = ChordClass.new [4,7,10,14]
  DOM_MIN_9 = ChordClass.new [4,7,10,13]

  MIN = ChordClass.new [3,7]
  MIN_6 = ChordClass.new [3,7,9]
  MIN_6_9 = ChordClass.new [3,7,9,14]
  MIN_7 = ChordClass.new [3,7,10]
  MIN_7_FLAT_5 = ChordClass.new [3,6,10]
  MIN_9 = ChordClass.new [3,7,10,14]
end

end
