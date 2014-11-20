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
      
      # add any immediate changes in segment
      changes.select {|o,c| c.is_a?(Change::Immediate) && seg.include?(o) }.each do |off,c|
	new_changes[(off - seg.first) + segment_start_offset] = c.clone
      end
      
      # add gradual changes
      changes.select {|o,c| c.is_a?(Change::Gradual)}.each do |off, change|
	adj_start_off = (off - seg.first) + segment_start_offset
	end_off = off + change.duration
	if seg.include?(off) # change that are wholly included in segment
	  if end_off <= seg.last
	    new_changes[adj_start_off] = change.clone
	  else # change that overlap segment end
	    over = end_off - seg.last
	    new_changes[adj_start_off] = Change::Gradual.new(change.value,
	      change.duration - over, change.elapsed, change.remaining + over)
	  end
	elsif end_off > seg.first && end_off < seg.last # change that overlap segment start
	  under = seg.first - off
	  new_changes[segment_start_offset] = Change::Gradual.new(change.value,
	    change.duration - under, change.elapsed + under, change.remaining)
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
