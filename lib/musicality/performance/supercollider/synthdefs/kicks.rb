module Musicality
module SuperCollider
module SynthDefs
#
# KICK808 = SynthDef.new(name: "kick808", params: { :out => 0 },
#   body: <<-SCLANG,
#   var sig = LPF.ar(Ringz.ar(Impulse.ar(0), 60, 1), 500);
#   var cmp = CompanderD.ar(sig, -20.dbamp, 1, 0.3, 0.003, 0.08);
#
#   cmp = cmp * (10.dbamp);
#   Out.ar(out, cmp.dup);
# SCLANG
#   source: "https://github.com/acarabott/roundhouse-synth-design-course-2014"
# )


KICK808 = SynthDef.new(name: "kick808", params: { :out => 0, :freq => 440, :amp => 0.1,
    :ringTime => 10.0, :releaseTime => 1.0, :distortion => 0.1, :pan => -0.1 },
  body: <<-SCLANG,
  var impulse, filter, env;

  impulse = Impulse.ar(0);
  filter = Ringz.ar(impulse,XLine.ar(freq,60,0.1),ringTime);
  env = EnvGen.ar(Env.perc(0.001,releaseTime),doneAction:2);
  filter = (1.0-distortion)*filter + (distortion*(filter.distort));

  Out.ar(out,Pan2.ar(filter*env*amp,pan));
SCLANG
  credit: <<-EOS,
Sound recipes from:
Mitchell Sigman (2011) Steal this Sound. Milwaukee, WI: Hal Leonard Books
adapted for SuperCollider and elaborated by Nick Collins (http://www.sussex.ac.uk/Users/nc81/index.html)
under GNU GPL 3  as per SuperCollider license
EOS
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

KICK2 = SynthDef.new(name: "kick2", params: { :out => 0, :amp => 0.2 },
  body: <<-SCLANG,
  var env0, env1, env1m, sig;

  env0 =  EnvGen.ar(
    Env([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), doneAction:2
  );
  env1 = EnvGen.ar(Env([110, 59, 29], [0.005, 0.29], [-4, -5]));
  env1m = env1.midicps;

  sig = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
  sig = sig + WhiteNoise.ar(1);
  sig = LPF.ar(sig, env1m * 1.5, env0);
  sig = sig + SinOsc.ar(env1m, 0.5, env0);

  sig = sig * 1.2;
  sig = sig.clip2(1);

  Out.ar(out, sig.dup * amp);
SCLANG
  credit: "Reformatted for the Roundhouse Synth Design course from 08091500Acid309 by otophilia from SuperCollider/examples folder",
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

KICK3 = SynthDef.new(name: "kick3", params: { :out => 0, :punch => 1, :amp => 1 },
  body: <<-SCLANG,
  var freq = EnvGen.kr(Env([400, 66], [0.08], -3)),
  sig = Normalizer.ar(SinOsc.ar(freq, 0.5pi, punch).distort, 1) * amp
            * EnvGen.kr(Env([0, 1, 0.8, 0], [0.01, 0.1, 0.2]), doneAction: 2);
    Out.ar(out, sig ! 2);
SCLANG
  source: "From https://github.com/brunoruviaro/SynthDefs-for-Patterns",
)

RING_KICK = SynthDef.new(name: "ringkick", params: { :out => 0, :freq => 40, :decay => 0.05, :amp => 1 },
  body: <<-SCLANG,
  var snd;
  snd = Ringz.ar(
    in: LPF.ar(
      in: Impulse.ar(0),
      freq: 1000),
    freq: freq,
    decaytime: decay,
    mul: 7 * amp).tanh.sin*2;
  Out.ar(out, snd!2);
SCLANG
  source: "From https://github.com/brunoruviaro/SynthDefs-for-Patterns",
)

KICK_CHIRP = SynthDef.new(name: "kick_chrp", params: { :out => 0, :amp => 1, :pan => 0 },
  body: <<-SCLANG,
  // a kick made using what radio folks would call a "chirp"
  var ampenv, pitchenv;

  ampenv   = EnvGen.ar(Env.perc(0, 0.2, curve: 0), doneAction: 2);
  pitchenv = EnvGen.ar(Env.perc(0, 0.1, curve: -20).exprange(0, 1000), doneAction: 0);

  Out.ar(out, Pan2.ar(SinOsc.ar(pitchenv) * amp, pan));
SCLANG
  credit: "by dan stowell. public domain",
  source: "https://github.com/supercollider-quarks/SynthDefPool",
)

KICK_OTO_309 = SynthDef.new(name: "kick_oto309", params: { :out => 0, :amp => 0.1, :pan => 0 },
  body: <<-SCLANG,
  var env0, env1, env1m, son;

  env0 =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), doneAction:2);
  env1 = EnvGen.ar(Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]));
  env1m = env1.midicps;

  son = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
  son = son + WhiteNoise.ar(1);
  son = LPF.ar(son, env1m*1.5, env0);
  son = son + SinOsc.ar(env1m, 0.5, env0);

  son = son * 1.2;
  son = son.clip2(1);

  Out.ar(out, Pan2.ar(son * amp));
SCLANG
  credit: "from 08091500Acid309 by_otophilia",
  source: "https://github.com/supercollider-quarks/SynthDefPool",
)


# KIK = SynthDef.new(name: "kik", params: { :out => 0, :basefreq => 50, :ratio => 7, :sweeptime => 0.05, :preamp => 1, :amp => 1, :decay1 => 0.3, :decay1L => 0.8, :decay2 => 0.15 },
#   body: <<-SCLANG,
#     var fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp)),
#         env = EnvGen.kr(Env([1, decay1L, 0], [decay1, decay2], -4), doneAction: 2),
#         sig = SinOsc.ar(fcurve, 0.5pi, preamp).distort * env * amp;
#     Out.ar(out, sig ! 2)
# SCLANG
#   source: "From https://github.com/brunoruviaro/SynthDefs-for-Patterns",
# )

DRUM_KICK = SynthDef.new(name: "drum_kick", params: { :out => 0, :freq => 440, :gate => 1, :amp => 0.8, :source => nil,:pan => 0.0 },
  body: <<-SCLANG,
  var x1, x2, x3;

  x1 = SinOsc.ar(EnvGen.kr(Env.perc(0.0001, 1.5, 1, -200), gate, 1000, 45, doneAction:2), 1, 1);
  x2 = ((BPF.ar([GrayNoise.ar(6),GrayNoise.ar(6)],EnvGen.kr(Env.perc(0.001, 0.3, 1, -200), gate, 6000, 70), 1.5)).distort * Line.kr(0.3,0,0.1));
  x3 = EnvGen.kr(Env.perc(0.0001, 0.09, amp, 8));
  source = Pan2.ar(x1 + x2 * x3, 0);
  Out.ar(out, source);
SCLANG
  source: "https://github.com/willieavendano/SC-SynthDefs/blob/master/DrumMachines",
)

KICK1 = SynthDef.new(name: "kick", params: { :out => 0, :amp => 1, :dur => 0.05 },
  body: <<-SCLANG,
var tone;
tone = SinOsc.ar(XLine.ar(800,2,dur*4, mul: 0.2, doneAction:2));
Out.ar(out, amp * tone.dup * XLine.ar(2,1/1000,dur*4));
SCLANG
  source: "https://github.com/bwestergard/supercollider-experiments",
)

end
end
end
