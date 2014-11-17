module Musicality

require 'singleton'
class AccentedAttack
  include Singleton
  
  def accented?; return true; end
end

class UnaccentedAttack
  include Singleton
  
  def accented?; return false; end
end

ACCENTED = AccentedAttack.instance
UNACCENTED = UnaccentedAttack.instance

end