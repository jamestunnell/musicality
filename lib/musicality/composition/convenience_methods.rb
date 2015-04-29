module Musicality

def transpose notes, diff
  notes.map {|n| n.transpose(diff) }
end
module_function :transpose

def s(*pitch_groups)
  pitch_groups.map {|pg| Note.sixteenth(pg) }
end
module_function :s

def ds(*pitch_groups)
  pitch_groups.map {|pg| Note.dotted_sixteenth(pg) }
end
module_function :ds

def e(*pitch_groups)
  pitch_groups.map {|pg| Note.eighth(pg) }
end
module_function :e

def de(*pitch_groups)
  pitch_groups.map {|pg| Note.dotted_eighth(pg) }
end
module_function :e

def q(*pitch_groups)
  pitch_groups.map {|pg| Note.quarter(pg) }
end
module_function :q

def dq(*pitch_groups)
  pitch_groups.map {|pg| Note.dotted_quarter(pg) }
end
module_function :dq

def h(*pitch_groups)
  pitch_groups.map {|pg| Note.half(pg) }
end
module_function :h

def dh(*pitch_groups)
  pitch_groups.map {|pg| Note.dotted_half(pg) }
end
module_function :dh

def w(*pitch_groups)
  pitch_groups.map {|pg| Note.whole(pg) }
end
module_function :w

end