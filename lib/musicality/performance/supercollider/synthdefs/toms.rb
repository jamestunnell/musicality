module Musicality
module SuperCollider
module SynthDefs

TOM1 = SynthDef.new(name: "tom1", params: { :out => 0, :freq => 200, :amp => 1, :pan => 0.0 },
  body: <<-SCLANG,
  var env, tom;
  env = EnvGen.kr(Env.perc(0.001, 0.1, 1, -5), 1, doneAction:2);
  tom = SinOsc.ar(freq) * env;
  Out.ar(out, Pan2.ar(tom, pan, amp));
SCLANG
  source: "http://superdupercollider.blogspot.com/2009/02/simple-drum-machine.html"
)

FM_TOM = SynthDef.new(name: "fmtom", params: { :out => 0, :freq => 200, :gate => 1, :amp => 1 },
  body: <<-SCLANG,
  var tom = PMOsc.ar(freq, 280, Line.kr(0.0, 12, 1), mul: EnvGen.ar(Env.adsr(0.003,0.2,0,0), gate, levelScale: 0.3, doneAction: 2));
  Out.ar(out, tom * amp ! 2);
SCLANG
  source: "https://github.com/mattvears/supercollider-stuff",
)

end
end
end
