module Musicality
module SuperCollider

class Bundle
  attr_reader :time, :messages
  def initialize time, *messages
    @time = time
    @messages = messages
  end

  def to_sclang
    raise "Bundle contains no messages" if @messages.empty?
    "[ #{@time.to_f}, #{@messages.map {|m| m.to_sclang }.join(", ")} ]"
  end
end

end
end
