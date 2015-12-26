module Musicality
module SuperCollider

class SynthDef
  include Packable

  attr_reader :name, :args, :body, :credit, :source
  def initialize name: "", args: {}, body: "", credit: "", source: ""
    raise ArgumentError if name.empty?
    raise ArgumentError if body.empty?

    @name, @args, @body = name, args, body
    @credit, @source = credit, source
  end

  def to_sclang
    args_str = "|" + @args.map {|k,v| v.nil? ? k.to_s : "#{k} = #{v}" }.join(", ") + "|"
    output = "SynthDef(\"#{@name}\", {" + args_str + "\n" + @body + "\n}"
    
    if @credit || @source
      metadata_str = ", metadata: (\n"
      if @credit
        metadata_str += "  credit: \"#{@credit}\",\n"
      end
      if @source
        metadata_str += "  source: \"#{@source}\"\n"
      end
      metadata_str += ")\n"
      output += metadata_str
    end

    output += ").writeDefFile;"
  end

  class Settings
    include Packable

    attr_reader :synthdef, :values
    def initialize synthdef, values = {}
      @synthdef, @values = synthdef, values
    end
  end

  def settings values = {}
    Settings.new(self, values)
  end
end

end

class Part
  def synthdef_settings
    find_settings(SuperCollider::SynthDef::Settings)
  end
end

end
