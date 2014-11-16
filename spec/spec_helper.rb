require 'rspec'
require 'musicality'

include Musicality
include Pitches
include Meters
include Articulations

class Samples
  SAMPLE_PART = Part.new(
    Dynamics::P,
    notes: [
      Note::quarter([ C1, D1 ]),
      Note::quarter([ C2, D2 ]),
      Note::whole([ C3, D3 ])
    ],
    dynamic_changes: {1.0 => Change::Immediate.new(Dynamics::MP)}
  )
end

RSpec::Matchers.define :be_valid do
  match do |obj|
    obj.valid?
  end
end

RSpec::Matchers.define :be_invalid do
  match do |obj|
    obj.invalid?
  end
end

RSpec::Matchers.define :parse do |str|
  match do |parser|
    !parser.parse(str).nil?
  end
end

RSpec::Matchers.define :parse_as do |str,nodeclass|
  match do |parser|
    parser.parse(str).is_a?(nodeclass)
  end
end
