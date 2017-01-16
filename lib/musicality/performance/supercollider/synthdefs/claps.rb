module Musicality
module SuperCollider
module SynthDefs

ONECLAP = SynthDef.new(name: "oneclap", params: { :out => 0, :amp => 0.1, :filterfreq => 100, :rq => 0.1, :pan => 0 },
  body: <<-SCLANG,
var env, signal, attack, noise, hpf1, hpf2;
  noise = WhiteNoise.ar(1)+SinOsc.ar([filterfreq/2,filterfreq/2+4 ], pi*0.5, XLine.kr(1,0.01,4));
  //noise = PinkNoise.ar(1)+SinOsc.ar([(filterfreq)*XLine.kr(1,0.01,3), (filterfreq+4)*XLine.kr(1,0.01,3) ], pi*0.5, XLine.kr(1,0.01,4));
  //signal = signal * SinOsc.ar(1,0.75);
  hpf1 = RLPF.ar(noise, filterfreq, rq);
  hpf2 = RHPF.ar(noise, filterfreq/2, rq/4);
  env = EnvGen.kr(Env.perc(0.003, 0.00035));
  signal = (hpf1+hpf2) * env;
  signal = CombC.ar(signal, 0.5, 0.03, 0.031)+CombC.ar(signal, 0.5, 0.03016, 0.06);
  //signal = Decay2.ar(signal, 0.5);
  signal = FreeVerb.ar(signal, 0.23, 0.15, 0.2);
  Out.ar(out, Pan2.ar(signal * amp, pan));
  DetectSilence.ar(signal, doneAction:2);
SCLANG
  credit: "published on the sc-users list 2009-01-08 by thor",
  source: "https://github.com/supercollider-quarks/SynthDefPool",
)

CLAP_OTO_309 = SynthDef.new(name: "clap_oto309", params: { :out => 0, :amp => 0.6, :pan => 0 },
  body: <<-SCLANG,
  var env1, env2, son, noise1, noise2;

  env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
  env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.3], [0, -4]), doneAction:2);

  noise1 = WhiteNoise.ar(env1);
  noise1 = HPF.ar(noise1, 600);
  noise1 = BPF.ar(noise1, 2000, 3);

  noise2 = WhiteNoise.ar(env2);
  noise2 = HPF.ar(noise2, 1000);
  noise2 = BPF.ar(noise2, 1200, 0.7, 0.7);

  son = noise1 + noise2;
  son = son * 2;
  son = son.softclip * amp;

  Out.ar(out, Pan2.ar(son, pan));
SCLANG
  credit: "from 08091500Acid309 by_otophilia",
  source: "https://github.com/supercollider-quarks/SynthDefPool",
)

CLAP1 = SynthDef.new(name: "clap1", params: { :out => 0, :amp => 0.5 },
  body: <<-SCLANG,
  var env1, env2, sig, noise1, noise2;

  env1 = EnvGen.ar(Env(
    [0, 1, 0, 1, 0, 1, 0, 1, 0],
    [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03],
    [0, -3, 0, -3, 0, -3, 0, -4]
  ));
  env2 = EnvGen.ar(Env([0, 1, 0], [0.02, 0.3], [0, -4]), doneAction:2);

  noise1 = WhiteNoise.ar(env1);
  noise1 = HPF.ar(noise1, 600);
  noise1 = BPF.ar(noise1, 2000, 3);

  noise2 = WhiteNoise.ar(env2);
  noise2 = HPF.ar(noise2, 1000);
  noise2 = BPF.ar(noise2, 1200, 0.7, 0.7);

  sig = noise1 + noise2;
  sig = sig * 2;
  sig = sig.softclip * amp;

  Out.ar(out, sig.dup);
SCLANG
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

end
end
end
