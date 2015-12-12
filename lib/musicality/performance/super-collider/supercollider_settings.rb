module Musicality

class SuperColliderSettings
  include Packable

  attr_reader :synthdef, :settings

  def initialize synthdef, settings: {}
    @synthdef = synthdef
    @settings = settings
  end
end

end