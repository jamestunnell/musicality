module Musicality

# Combine functions that are each applicable for a non-overlapping domain.
#
# @author James Tunnell
class PiecewiseFunction
  attr_reader :pieces
  
  # Take an array of points (each point is a two-element array pair) and
  # create a piecewise function to calculate values in-between.
  def initialize points = []
    @pieces = { }
    
    points = points.sort_by {|p| p[0]}
    
    if points.count > 1
      if points.is_a?(Hash)
        points = points.to_a
      end
      
      for i in 1...points.count
        add_points points[i-1], points[i]
      end
    end
  end
  
  def add_points prev_point, point
    domain = prev_point[0]..point[0]
    func = lambda do |x|
      perc = (x - domain.min).to_f / (domain.max - domain.min)
      y = Interpolation.linear prev_point[1], point[1], perc
      return y
    end
    add_piece(domain, func)
  end
  
  # Add a function piece, which covers the given domain (includes domain start 
  # but not the end).
  # @param [Range] domain The function domain. If this overlaps an existing domain,
  #                       the existing domain will be split with the non-
  #                       overlapping pieces kept and the overlapping old piece
  #                       discarded.
  def add_piece domain, func
    
    raise ArgumentError, "domain is not a Range" if !domain.is_a? Range
    raise ArgumentError, "func is not a Proc" if !func.is_a? Proc
    
    contains_domain_completely = @pieces.select { |d,f| d.include?(domain.begin) && d.include?(domain.end) }
    if contains_domain_completely.any?
      contains_domain_completely.each do |d,f|
        l = d.begin...domain.begin
        if d.exclude_end?
          r = domain.end...d.end
        else
          r = domain.end..d.end
        end
        
        @pieces.delete d
        
        if domain.begin != d.begin
          @pieces[l] = f
        end
        if domain.end == d.end
          @pieces[domain.begin..domain.end] = func
        else
          @pieces[domain.begin...domain.end] = func
          @pieces[r] = f
        end
      end
    else
      delete_completely = @pieces.select { |d,f| domain.include?(d.begin) && domain.include?(d.end) }
      delete_completely.each do |d,f|
        @pieces.delete d
      end
      
      # should only be one
      move_end = @pieces.select { |d,f| domain.include?(d.end) }
      move_end.each do |d,f|
        @pieces.delete d
        @pieces[d.begin...domain.begin] = f
      end
      
      # should only be one
      move_begin = @pieces.select { |d,f| domain.include?(d.begin) }
      move_begin.each do |d,f|
        @pieces.delete d
        if d.exclude_end?
          @pieces[domain.end...d.end] = f
        else
          @pieces[domain.end..d.end] = f
        end
      end
      
      if move_begin.any?
        @pieces[domain.begin...domain.end] = func
      else
        @pieces[domain] = func
      end
    end
  end
  
  # Evaluate the piecewise function by finding a function piece whose domain 
  # includes the given independent value.
  def eval x
    y = nil
    
    @pieces.each do |domain, func|
      if domain.include? x
        y = func.call x
        break
      end
    end
    
    if y.nil?
      raise ArgumentError, "The input #{x} is not in the domain."
    end
    
    return y
  end
end

end