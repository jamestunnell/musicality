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
  end
  
  def collate_parts
    segments = @score.program.segments
    
    Hash[
      @score.parts.map do |name, part|
	new_dcs = collate_changes(part.start_dynamic,
	  part.dynamic_changes, segments)
	new_notes = collate_notes(part.notes, segments)
	new_part = Part.new(part.start_dynamic,
	  dynamic_changes: new_dcs, notes: new_notes)
	[ name, new_part ]
      end
    ]
  end
  
  def collate_tempo_changes
    collate_changes(@score.start_tempo,
      @score.tempo_changes, @score.program.segments)
  end
  
  def collate_meter_changes
    collate_changes(@score.start_meter,
      @score.meter_changes, @score.program.segments)
  end
  
  private
  
  def collate_changes start_value, changes, program_segments
    new_changes = {}
    comp = ValueComputer.new(start_value,changes)
    segment_start_offset = 0.to_r
    
    program_segments.each do |seg|
      seg = seg.first...seg.last
      
      # add segment start value
      value = comp.value_at seg.first
      new_changes[segment_start_offset] = Change::Immediate.new(value)
      
      changes.each do |off,change|
	adj_start_off = (off - seg.first) + segment_start_offset
	
	new_change = case change
	when Change::Immediate
	  change.clone if seg.include?(off)
	when Change::Gradual::Trimmed
	  raise NotImplementedError, "trimmed gradual changes are not supported yet"
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
    
    return new_changes
  end
  
  def collate_notes notes, program_segments
    new_notes = []
    program_segments.each do |seg|
      cur_offset = 0
      cur_notes = []
      
      l = 0
      while cur_offset < seg.first && l < notes.size
        cur_offset += notes[l].duration
        l += 1
      end
      
      pre_remainder = cur_offset - seg.first
      if pre_remainder > 0
        cur_notes << Note.new(pre_remainder)
      end
      
      # found some notes to add...
      if l < notes.size
        r = l
        while cur_offset < seg.last && r < notes.size
          cur_offset += notes[r].duration
          r += 1
        end
        
        cur_notes += Marshal.load(Marshal.dump(notes[l...r]))
        overshoot = cur_offset - seg.last
        if overshoot > 0
          cur_notes[-1].duration -= overshoot
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
