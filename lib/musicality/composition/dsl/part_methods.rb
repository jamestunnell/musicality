module Musicality

class Part
  def dynamic_change new_dynamic, transition_dur: 0, offset: 0
    if transition_dur == 0
      change = (transition_dur == 0) ? Change::Immediate.new(new_dynamic) : Change::Gradual.linear(new_dynamic, transition_dur)
      self.dynamic_changes[self.duration + offset] = change
    end
  end
end

end
