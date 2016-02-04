module Musicality

class AuditionDSL
  def self.load fname
    dsl = AuditionDSL.new
    dsl.instance_eval(File.read(fname), fname)
    dsl
  end

  attr_reader :auditions
  def initialize
    @auditions = []
  end

  def part_audition part_name, program, &block
    @auditions.push PartAudition.new(part_name, program)
    @auditions.last.instance_eval(&block)
  end
end

end
