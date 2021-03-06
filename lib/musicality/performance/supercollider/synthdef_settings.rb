module Musicality
module SuperCollider

class SynthdefSettings
  include Packable
  attr_reader :name, :args

  def initialize name, args={}
    @name, @args = name, args
  end
end

DEFAULT_SYNTHDEF_SETTINGS = DEFAULT_SYNTHDEF.settings

end

class Part
  def synthdef_settings
    find_settings(SuperCollider::SynthdefSettings)
  end
end

end