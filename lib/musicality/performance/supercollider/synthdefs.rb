module Musicality
module SuperCollider
module SynthDefs

VOLUME_CONTROL = SynthDef.new(
  :name => "volume_control",
  :args => { :in => nil, :out => nil, :control => nil },
  :credit => "James Tunnell",
  :body => "  Out.ar(out, In.ar(in) * In.kr(control));"
)
 
VOLUME_CHANGE = SynthDef.new(
  :name => "volume_change",
  :args => { :vol_bus => nil, :vol => nil, :dur => nil },
  :credit => "James Tunnell",
  :body => "  Out.kr(vol_bus, Line.kr(In.kr(vol_bus), vol, dur));"
)

AXEL = DEFAULT_SYNTHDEF = SynthDef.new(
  :name => "axel",
  :args => { :freq => 440, :lpfreq => 12000, :rq => 0.2, :gate => 1, :out => 0 },
  :credit => "By Arthur Carabott, based on Sound on Sound article",
  :source => "https://github.com/acarabott/roundhouse-synth-design-course-2014",
  :body => <<-SCLANG
  var chorus = LFNoise2.ar(1).range(0.99, 1.01);
  var saw1 = LFSaw.ar(freq * chorus, 0, 0.1);
  var saw2 = LFSaw.ar((freq.cpsmidi - 0.1).midicps * chorus, 0, 0.1);
  var tri = LFTri.ar(freq * chorus, 0, 0.1);
  var mix = Mix([saw1, saw2, tri]);
  var lpf = RLPF.ar(mix, lpfreq, rq);
  var env = EnvGen.ar(Env.adsr(0.3, 0.6, 0.5, 0.25), gate, doneAction: 2);
  Out.ar(out, Pan2.ar(lpf * env, 0));
SCLANG
)

BRASS = SynthDef.new(
  :name => "brass",
  :args => { :freq => 220, :detune1 => 1, :detune2 => 0.5, :ffreq => 12000, :rq => 0.4,
    :pan => 0, :gate => 1, :out => 0 },
  :credit => "Based on Sound on Sound Synth Secrets Part 25 by Arthur Carabott",
  :source => "https://github.com/acarabott/roundhouse-synth-design-course-2014",
  :body => <<-SCLANG
  var sig, env, fenv;

  sig = Mix([freq, freq - detune1, freq + detune2, freq / 2].collect {|freq|
    LFSaw.ar(freq);
  });
  fenv = EnvGen.kr(Env([ffreq, 0], [0.06], \\sin));
  sig = RHPF.ar(sig, fenv, rq);
  env = EnvGen.ar(Env.asr(0.01, 1, 0.1), gate, doneAction:2);

  Out.ar(out, Pan2.ar(sig * env * 0.2, pan));
SCLANG
)

BASS2 = SynthDef.new(
  :name => "bass2",
  :args => { :out => 0, :freq => 440, :gate => 1, :amp => 1.0, :slideTime => 0.17, :ffreq => 1100, :width => 0.15,
    :detune => 1.005, :preamp => 4, :dur => 0.2, :length => 0.2 },
  :body => <<-SCLANG
  var sig, env = Env.adsr(0.01, 0.3, 0.4, 0.1);
  freq = Lag.kr(freq, slideTime);
  sig = Mix(VarSaw.ar([freq, freq * detune], 0, width, preamp)).distort * amp
    * EnvGen.kr(env, gate * dur * length , doneAction: 2);
  sig = LPF.ar(sig, ffreq);
  Out.ar(out, sig ! 2);
SCLANG
)

end
end
end