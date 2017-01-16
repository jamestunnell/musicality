module Musicality
module SuperCollider
module SynthDefs

SNARE1 = SynthDef.new(name: "snare1", params: { :out => 0, :amp => 0.8 },
  body: <<-SCLANG,
  var env0, env1, env2, env1m, oscs, noise, sig;

  env0 = EnvGen.ar(Env([0.5, 1, 0.5, 0], [0.005, 0.03, 0.10], [-4, -2, -4]));
  env1 = EnvGen.ar(Env([110, 60, 49], [0.005, 0.1], [-4, -5]));
  env1m = env1.midicps;
  env2 = EnvGen.ar(Env([1, 0.4, 0], [0.05, 0.13], [-2, -2]), doneAction:2);

  oscs = LFPulse.ar(env1m, 0, 0.5, 1, -0.5) +
  LFPulse.ar(env1m * 1.6, 0, 0.5, 0.5, -0.25);
  oscs = LPF.ar(oscs, env1m * 1.2, env0);
  oscs = oscs + SinOsc.ar(env1m, 0.8, env0);

  noise = WhiteNoise.ar(0.2);
  noise = HPF.ar(noise, 200, 2);
  noise = BPF.ar(noise, 6900, 0.6, 3) + noise;
  noise = noise * env2;

  sig = oscs + noise;
  sig = sig.clip2(1) * amp;

  Out.ar(out, sig.dup);
SCLANG
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

SNARE2 = SynthDef.new(name: "snare2", params: { :sfreq => 1500, :out => 0 },
  body: <<-SCLANG,
  var tri = Mix([LFTri.ar([111, 175, 224])]) * 0.5;
  var sine = Mix([SinOsc.ar([330, 180])]) * 0.5;
  var env = EnvGen.ar(Env.perc(0.01, 0.2), doneAction:2);
  var snares = WhiteNoise.ar(1);
  var snareEnv = EnvGen.ar(Env.perc(0.01, 0.2));

  snares = HPF.ar(snares, sfreq);
  snares = snares * snareEnv;

  Out.ar(out, Mix([tri, sine, snares]) * env);
SCLANG
  credit: "Based on Sound on Sound Synth Secrets 35, by Arthur Carabott",
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

SOS_SNARE = SynthDef.new(name: "SOSsnare", params: { :out => 0, :decay => 0.12, :drum_mode_level => 0.25, :snare_level => 40, :snare_tightness => 3000, :freq => 405, :amp => 0.8 },
  body: <<-SCLANG,
  var drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix,
drum_mode_env;
  var snare_noise, snare_brf_1, snare_brf_2, snare_brf_3, snare_brf_4,
snare_reson;
  var snare_env;
  var snare_drum_mix;

  drum_mode_env = EnvGen.ar(Env.perc(0.005, decay), 1.0, doneAction: 2);
  drum_mode_sin_1 = SinOsc.ar(freq*0.53, 0, drum_mode_env * 0.5);
  drum_mode_sin_2 = SinOsc.ar(freq, 0, drum_mode_env * 0.5);
  drum_mode_pmosc = PMOsc.ar( Saw.ar(freq*0.85), 184, 0.5/1.3, mul: drum_mode_env*5, add: 0);
  drum_mode_mix = Mix.new([drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc]) * drum_mode_level;

  // choose either noise source below
  //  snare_noise = Crackle.ar(2.01, 1);
  snare_noise = LFNoise0.ar(20000, 0.1);
  snare_env = EnvGen.ar(Env.perc(0.005, decay, curve:-5), 1.0, doneAction: 2);
  snare_brf_1 = BRF.ar(in: snare_noise, freq: 8000, mul: 0.5, rq: 0.1);
  snare_brf_2 = BRF.ar(in: snare_brf_1, freq: 5000, mul: 0.5, rq: 0.1);
  snare_brf_3 = BRF.ar(in: snare_brf_2, freq: 3600, mul: 0.5, rq: 0.1);
  snare_brf_4 = BRF.ar(in: snare_brf_3, freq: 2000, mul: snare_env, rq: 0.0001);
  snare_reson = Resonz.ar(snare_brf_4, snare_tightness, mul: snare_level) ;
  snare_drum_mix = Mix.new([drum_mode_mix, snare_reson]) * 5 * amp;
  Out.ar(out, [snare_drum_mix, snare_drum_mix])
SCLANG
  credit: "recipe basically from Gordon Reid
http://www.soundonsound.com/sos/Mar02/articles/synthsecrets0302.asp
programmed by Renick Bell, renick_at_gmail.com",
  source: "https://github.com/willieavendano/SC-SynthDefs/blob/master/DrumMachines",
)

SNARE_OTO_309 = SynthDef.new(name: "snare_oto309", params: { :out => 0, :amp => 0.1, :pan => 0 },
  body: <<-SCLANG,
  var env0, env1, env2, env1m, oscs, noise, son;

  env0 = EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.03, 0.10], [-4, -2, -4]));
  env1 = EnvGen.ar(Env.new([110, 60, 49], [0.005, 0.1], [-4, -5]));
  env1m = env1.midicps;
  env2 = EnvGen.ar(Env.new([1, 0.4, 0], [0.05, 0.13], [-2, -2]), doneAction:2);

  oscs = LFPulse.ar(env1m, 0, 0.5, 1, -0.5) + LFPulse.ar(env1m * 1.6, 0, 0.5, 0.5, -0.25);
  oscs = LPF.ar(oscs, env1m*1.2, env0);
  oscs = oscs + SinOsc.ar(env1m, 0.8, env0);

  noise = WhiteNoise.ar(0.2);
  noise = HPF.ar(noise, 200, 2);
  noise = BPF.ar(noise, 6900, 0.6, 3) + noise;
  noise = noise * env2;

  son = oscs + noise;
  son = son.clip2(1) * amp;

  Out.ar(out, Pan2.ar(son, pan));
SCLANG
  credit: "from 08091500Acid309 by_otophilia",
  source: "https://github.com/supercollider-quarks/SynthDefPool",
)

SNARE_STEIN = SynthDef.new(name: "snare_stein", params: { :out => 0, :amp => 0.1, :pan => 0 },
  body: <<-SCLANG,
  var snare, filtWhite;

  filtWhite = LPF.ar(WhiteNoise.ar(1), 7040, 1);

  snare = (SinOsc.ar(330,0,0.25) * EnvGen.ar(Env.perc(0.0005,0.055))) + (SinOsc.ar(185,0,0.25) * EnvGen.ar(Env.perc(0.0005,0.075))) + (filtWhite * EnvGen.ar(Env.perc(0.0005,0.2), doneAction: 2) * 0.2) + (HPF.ar(filtWhite, 523, 1) * EnvGen.ar(Env.perc(0.0005,0.183)) * 0.2);
  Out.ar(out, Pan2.ar(snare * amp * 10, pan));
SCLANG
  credit: "Snare written by Esben Stein, I believe",
  source: "https://github.com/supercollider-quarks/SynthDefPool",
)

SNARE3 = SynthDef.new(name: "snare", params: { :amp => 1, :dur => 0.05, :out => 0 },
  body: <<-SCLANG,
dur = dur * 16;
Out.ar(out, amp * XLine.ar(2,1/1000,dur) * BPF.ar(PinkNoise.ar(0.8), XLine.ar(20000,1000,dur, doneAction:2), 0.8).dup);
SCLANG
  source: "https://github.com/bwestergard/supercollider-experiments",
)

SNARE_909 = SynthDef.new(name: "snare909", params: { :out => 0, :lpFreq => 1000, :vol => 1, :gate => 1 },
  body: <<-SCLANG,
  var sig1, sig2;
  var triEnv;
  var shifted1;
  var shifted2;
  var sinEnv;
  var sin1, sin2;
  var mixed;
  var sig3;
  var noiseEnv;

  // tri -> final mixer
  triEnv = Env.adsr(0, 0.4, 0, 0, curve: -4,  peakLevel: 0.5);
  sig1 = LFTri.ar(111, 0, 0.5) * EnvGen.kr(triEnv, gate: gate, doneAction: 2);
  shifted1 = FreqShift.ar(sig1, 175);
  shifted2 = FreqShift.ar(sig1, 224);
  sig1 = Mix.new([shifted1, shifted2]);

  // sines -> final mixer
  sin1 = SinOsc.ar(330, mul: 0.2);
  sin2 = SinOsc.ar(180, mul: 0.2);
  sinEnv = Env.adsr(0, 0.2, 0, 0);
  sig2 = Mix.new([sin1, sin2]) * EnvGen.kr(sinEnv, gate: gate, doneAction: 2);

  // noise -> final mixer
  noiseEnv = Env.adsr(0, 0.3, 0, 0);
  sig3 = LPF.ar(WhiteNoise.ar() * EnvGen.kr(noiseEnv, gate: gate, doneAction: 2), 1000);
  sig3 = HPF.ar(sig3, 600);

  mixed = Mix.new([sig1, sig2, sig3]);
  mixed = LPF.ar(mixed, lpFreq) * vol;
  Out.ar(out, mixed  ! 2);
SCLANG
  source: "https://github.com/mattvears/supercollider-stuff",
)

end
end
end
