module Musicality

class Audition
  attr_reader :part_name, :program, :performers
  def initialize part_name, program
    @part_name = part_name
    @program = program.is_a?(Array) ? program : [program]
    @performers = {}
  end

  def performer name, supercollider_settings
    @performers[name] = supercollider_settings
  end
end

end
