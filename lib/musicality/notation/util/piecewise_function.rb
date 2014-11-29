module Musicality

class Function
  # Combine functions that are each applicable for a non-overlapping domain.
  #
  # @author James Tunnell
  class Piecewise < Function
    attr_reader :pieces
    
    # Take an array of points (each point is a two-element array pair) and
    # create a piecewise function to calculate values in-between.
    def initialize
      @pieces = { }
    end
    
    # Add a function piece, which covers the given domain (includes domain start 
    # but not the end).
    # @param [Range] domain The function domain. If this overlaps an existing domain,
    #                       the existing domain will be split with the non-
    #                       overlapping pieces kept and the overlapping old piece
    #                       discarded.
    def add_piece domain, func
      
      raise ArgumentError, "domain is not a Range" unless domain.is_a? Range
      raise ArgumentError, "func is not a Function" unless func.is_a? Function
      
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
      @pieces.each do |domain, func|
        if domain.include? x
          return func.eval(x)
        end
      end
      raise ArgumentError, "The input #{x} is not in the domain."
    end
  end
end

end