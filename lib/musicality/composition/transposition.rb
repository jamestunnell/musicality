module Musicality

def transpose notes, diff
  notes.map {|n| n.transpose(diff) }
end
module_function :transpose

end
