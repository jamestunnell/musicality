module Musicality
module SuperCollider
module SynthDefs

HIHAT1 = SynthDef.new(name: 'hihat1', params: { :out => 0, :pan => 0, :amp => 1, :release => 0.2 },
  body: <<-SCLANG,
  var click, clickAmp;
  var noise, noiseAmp;
  var snd;

  // noise -> resonance -> expodec envelope
  noiseAmp = EnvGen.ar(Env.perc(0.001, release, curve: -8), doneAction: 2);
  noise = Mix(BPF.ar(ClipNoise.ar, [4010, 4151], [0.15, 0.56], [1.0, 0.6])) * 0.7 * noiseAmp;

  snd = noise;

  Out.ar(out, Pan2.ar(snd, pan, amp));
SCLANG
  source: "http://sccode.org/1-523"
)

HAT808 = SynthDef.new(name: "hat808", params: { :out => 0, :freq => 230, :hpf => 6500, :release => 0.15, :amp => 1, :fxb => 0, :fxv => 0, :bbcb => 0, :bbcv => 0 },
  body: <<-SCLANG,
  var pulse, sig, env, freqs;
  freqs = [freq, freq*1.4471, freq*1.617, freq*1.9265, freq*2.5028, freq*2.6637];
  pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6, mul: 0.15));
  sig = RHPF.ar(RHPF.ar(pulse, hpf), hpf);
  env = EnvGen.kr(Env.perc(0,release),doneAction:2);
  sig = sig*env;
  Out.ar(out, Pan2.ar(sig*amp,0));
SCLANG
  credit: "Christoph Kummerer",
  source: "http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/High-Hats-td4823993.html"
)

CLOSED_HAT = SynthDef.new(name: "closedhat", params: { :out => 0, :lpf => 8000, :hpf => 2400, :amp => 1 },
  body: <<-SCLANG,
  var hatosc, hatenv, hatnoise, hatoutput;

  hatnoise = {LPF.ar(WhiteNoise.ar(1),lpf)};
  hatosc = {HPF.ar(hatnoise,hpf)};
  hatenv = {Line.ar(1, 0, 0.1)};
  hatoutput = (hatosc * hatenv);

  Out.ar(out, Pan2.ar(hatoutput*amp, 0));
SCLANG
  source: "https://github.com/willieavendano/SC-SynthDefs/blob/master/DrumMachines",
)

OPEN_HAT = SynthDef.new(name: 'openhat', params: { :out => 0, :lpf => 6000, :hpf => 2000, :amp => 1 },
  body: <<-SCLANG,
  var hatosc, hatenv, hatnoise, hatoutput;

  hatnoise = {LPF.ar(WhiteNoise.ar(1),lpf)};
  hatosc = {HPF.ar(hatnoise,hpf)};
  hatenv = {Line.ar(1, 0, 0.3)};
  hatoutput = (hatosc * hatenv);

  Out.ar(out, Pan2.ar(hatoutput*amp, 0));
SCLANG
  credit: "Rumblesan",
  source: "http://blog.rumblesan.com/post/53271713518/drum-sounds-in-supercollider-part-1"
)

end
end
end
