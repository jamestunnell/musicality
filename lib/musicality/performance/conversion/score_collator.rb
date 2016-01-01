module Musicality

class ScoreNotValidError < StandardError; end

# Combine multiple program segments to one, using tempo/note/dynamic
# replication and truncation where necessary.
class ScoreCollator
  def initialize score
    unless score.valid?
      raise ScoreNotValidError, "errors found in score: #{score.errors}"
    end
    @score = score
    @program = score.program.any? ? score.program : [0...score.duration]
  end
  
  def collate_parts
    Hash[
      @score.parts.map do |name, part|
        dyn_comp = ValueComputer.new(part.start_dynamic,part.dynamic_changes)

        new_part = part.clone
        new_part.notes = collate_notes(part.notes, @program)
        new_part.start_dynamic, new_part.dynamic_changes = collate_changes(
          part.start_dynamic, part.dynamic_changes, @program
        )
        [ name, new_part ]
      end
    ]
  end
  
  def collate_tempo_changes
    collate_changes(@score.start_tempo, @score.tempo_changes, @program)
  end
  
  def collate_meter_changes
    collate_changes(@score.start_meter, @score.meter_changes, @program)
  end
  
  def collate_key_changes
    collate_changes(@score.start_key, @score.key_changes, @program)
  end

  private
  
  def collate_changes start_value, changes, program_segments
    new_changes = {}
    comp = ValueComputer.new(start_value, changes)
    segment_start_offset = 0.to_r
    
    new_start_val = comp.at(program_segments.first.first)
    
    program_segments.each_with_index do |seg, i|
      seg = seg.first...seg.last
      
      # add segment start value, but only if it's different than the value at 
      # the end of the prev segment
      value = comp.at seg.first
      if i != 0 && comp.at(program_segments[i-1].last - 1e-5) != value
        new_changes[segment_start_offset] = Change::Immediate.new(value)
      end
      
      changes.each do |off,change|
	       adj_start_off = (off - seg.first) + segment_start_offset

      	new_change = case change
      	when Change::Immediate
      	  change.clone if seg.include?(off)
      	when Change::Gradual::Trimmed
      	  end_off = off + change.remaining
      	  if off < seg.last && end_off > seg.first
      	    add_preceding = seg.first > off ? seg.first - off : 0
      	    add_trailing = end_off > seg.last ? end_off - seg.last : 0

      	    if add_preceding == 0 && add_trailing == 0
      	      change.clone
      	    else
      	      adj_start_off += add_preceding
      	      change.untrim.trim(change.preceding + add_preceding,
      				 change.trailing + add_trailing)
      	    end
      	  end
      	when Change::Gradual
      	  end_off = off + change.duration
      	  if off < seg.last && end_off > seg.first
      	    preceding = seg.first > off ? seg.first - off : 0
      	    trailing = end_off > seg.last ? end_off - seg.last : 0
      	    if preceding == 0 && trailing == 0
      	      change.clone
      	    else
      	      adj_start_off += preceding
      	      change.trim(preceding, trailing)
      	    end
      	  end
      	end
      	
      	unless new_change.nil?
      	  new_changes[adj_start_off] = new_change
      	end
      end
    end
    
    return new_start_val, new_changes
  end
  
  def collate_notes notes, program_segments
    new_notes = []
    program_segments.each do |seg|
      cur_offset = 0
      cur_notes = []
      
      i = 0
      while cur_offset < seg.first && i < notes.size
        cur_offset += notes[i].duration
        i += 1
      end
      
      pre_remainder = cur_offset - seg.first
      if pre_remainder > 0
        cur_notes << Note.new(pre_remainder)
      end
      
      # found some notes to add...
      if i < notes.size
        while cur_offset < seg.last && i < notes.size
          cur_notes << notes[i].clone
          cur_offset += notes[i].duration
          i += 1
        end
        overshoot = cur_offset - seg.last
        if overshoot > 0
          cur_notes.last.duration = cur_notes.last.duration - overshoot
          cur_offset = seg.last
        end
      end
      
      post_remainder = seg.last - cur_offset
      if post_remainder > 0
        cur_notes << Note.new(post_remainder)
      end
        
      new_notes.concat cur_notes
    end
    return new_notes
  end
end

end
