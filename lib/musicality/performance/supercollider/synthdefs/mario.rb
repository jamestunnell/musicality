module Musicality
module SuperCollider
module SynthDefs

MARIO = SynthDef.new(name: "mario", params: { :out => 0, :freq => 440, :length => 0.1, :dur => 0.2 },
  body: <<-SCLANG,
  var snd, amp;
  snd = LFPulse.ar(freq)!2;
  amp = LFTri.ar(freq/50)!2;
  snd = snd * EnvGen.ar(Env.linen(0.001, length * dur, 0.03), doneAction:2);
  OffsetOut.ar(out, snd*amp);
SCLANG
  source: "https://github.com/mtytel/supersongs/",
)

MARIO_BASS = SynthDef.new(name: "mariobass", params: { :out => 0, :amp => 1.0, :freq => 440, :length => 0.1, :dur => 0.2 },
  body: <<-SCLANG,
  var snd;
  snd = LFTri.ar(freq)!2;
  snd = snd * EnvGen.ar(Env.linen(0.001, length * dur, 0.03), doneAction:2);
  OffsetOut.ar(out, snd*amp);
SCLANG
  source: "https://github.com/mtytel/supersongs/",
)

BEAT = SynthDef.new(name: "beat", params: { :out => 0, :amp => 1.0, :sustain => 0.1, :dur => 0.1 },
  body: <<-SCLANG,
  var snd;
  snd = BrownNoise.ar()!2;
  snd = HPF.ar(snd, 2000);
  snd = snd * EnvGen.ar(Env.linen(0.005, dur * sustain, 0.01), doneAction:2);
  OffsetOut.ar(out, snd*amp);
SCLANG
  source: "https://github.com/mtytel/supersongs/",
)

BOOP = SynthDef.new(name: "boop", params: { :out => 0, :dur => 1.0, :amp => 1.0, :freq => 440 },
  body: <<-SCLANG,
  var env, sig;
  env = EnvGen.ar(Env.new([1, 0.1, 0], [0.06, dur - 0.06]), doneAction: 2);
  sig = LFTri.ar([freq * 0.995, freq * 1.005], 0, env * amp);
  Out.ar(out, sig ! 2);
SCLANG
  source: "https://github.com/mtytel/supersongs/",
)

end
end
end
