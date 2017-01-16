module Musicality

# A collection of settings for performing drum parts
class DrumKit
  attr_reader :part_settings
  def initialize part_settings
    non_drumpart_names = part_settings.select do |part_name|
      !DRUM_PARTS.include?(part_name)
    end
    if non_drumpart_names.any?
      raise ArgumentError, "Part-names used that are not drum parts: #{non_drumpart_names.inspect}"
    end

    @part_settings = part_settings.freeze
  end
end

end
