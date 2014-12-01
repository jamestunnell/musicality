module Musicality

class Transition < Function::Piecewise
  def initialize func, transition_domain
    super()
    add_piece(transition_domain, func)
    add_piece(transition_domain.last..DOMAIN_MAX,
              Function::Constant.new(func.at(transition_domain.last)))
  end
end

end
