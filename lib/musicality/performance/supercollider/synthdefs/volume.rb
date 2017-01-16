module Musicality
module SuperCollider
module SynthDefs

VOLUME_CONTROL = SynthDef.new(name: "volume_control", params: { :in => nil, :out => nil, :control => nil },
  body: <<-SCLANG,
  var sig = In.ar([in,in+1]) * In.kr(control);
  Out.ar(out,sig);
SCLANG
  credit: "James Tunnell",
)

VOLUME_CHANGE = SynthDef.new(name: "volume_change", params: { :vol_bus => nil, :vol => nil, :dur => nil },
  body: "  Out.kr(vol_bus, Line.kr(In.kr(vol_bus), vol, dur));",
  credit: "James Tunnell",
)

end
end
end
