module Musicality

class Chord
#   attr_reader :root_pc, :intervals
#
#   def initialize root_pc, intervals
#     raise ArgumentError, "Intervals should be positive" if intervals.any? {|i| i <= 0}
#     @root_pc = PitchClass.from_i(root_pc)
#     @intervals = intervals
#   end
#
#   def pitch_classes
#     AddingSequence.new(@intervals, start_pitch)
#   end
#
#   def rotate rotate_n
#
#   end
#
#   def transpose semitone_shift
#     Chord.new(@root_pc + semitone_shift, @intervals)
#   end
end

end
