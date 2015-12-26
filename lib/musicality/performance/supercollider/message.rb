module Musicality
module SuperCollider

class Message
  attr_reader :address, :args
  def initialize address, *args
    @address = address
    @args = args
  end

  def to_sclang
    arg_strs = @args.map do |arg|
      case arg
      when Symbol, String
        "\"#{arg.to_s}\""
      else
        arg.to_s
      end
    end

    "[\"#{@address}\", #{arg_strs.join(", ")}]"
  end
end

end
end
