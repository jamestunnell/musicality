module Musicality
module SuperCollider
module SynthDefs

CYMBAL_808 = SynthDef.new(name: "cymbal808", params: { :out => 0, :baseFreq => 300, :time => 250, :amp => 0.1 },
  body: <<-SCLANG,
  //var freqs = [baseFreq, baseFreq*1.3420, baseFreq*1.2312, baseFreq*1.6532, baseFreq*1.9523, baseFreq*2.1523];
  //var freqs = [78.6, 140.44, 123.87, 219.4, 787.5, 531.3];
  //var freqs = [205.35, 254.29, 294.03, 304.41, 369.64, 522.71];
  var freqs = [205.35, 304.41, 369.64, 522.71, 540.54, 812.21];
  var signal, pulseEnv;

  pulseEnv = EnvGen.ar(Env.new([1.0, 0.6], [time], [-0.5]), timeScale:(1/1000));
  signal = Mix.new(LFPulse.ar(freqs * 4.09));
  signal = (BinaryOpUGen('==', signal, 6.0) * 0.6) + (BinaryOpUGen('==', signal, 2.0) * 0.2) + (BinaryOpUGen('==', signal, 1.0) * 0.9); // XOR
  signal = (signal * pulseEnv) + (Mix.new(LFPulse.ar(freqs, width:0.55)) * 0.9);
  signal = RLPF.ar(signal, 7000, 0.6);
  signal = RHPF.ar(signal, 6800, 1.5);
  signal = RHPF.ar(signal, 6800, 1.5);
  signal = RHPF.ar(signal, 1200, 1.5);
  signal = signal + FreeVerb.ar(signal);
  signal = signal * EnvGen.ar(Env.new([0, 1, 0.4, 0, 0], [2, time, 50, 500], [0, -0.5, 0, -50]), timeScale:(1/1000), doneAction:2);
  signal = [signal, DelayN.ar(signal, 0.005, 0.005)];
  OffsetOut.ar(out, signal*amp ! 2);
SCLANG
  credit: "Published on sc-users 2007-08-25 by Ryan Brown",
  source: "https://github.com/supercollider-quarks/SynthDefPool",
)

CYMBALIC_MCLD = SynthDef.new(name: "cymbalic_mcld", params: { :out => 0, :pan => 0, :amp => 0.1,
  :lo_attack => 0.1, :lo_release => 1, :hi_attack => 0.2, :hi_release => 1 },
  body: <<-SCLANG,
  var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack;

  locutoffenv = EnvGen.ar(Env.perc(lo_attack, lo_release)) * 20000 + 10;
  lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);

  hicutoffenv = 10001 - (EnvGen.ar(Env.perc(hi_attack, hi_release)) * 10000);
  hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv);
  hidriver = hidriver * EnvGen.ar(Env.perc(hi_attack, hi_release * 0.75, 0.25));

  thwack = EnvGen.ar(Env.perc(0.001,0.001,0.5));

  // This bit will regenerate new freqs every time you evaluate the SynthDef!
  freqs  = {exprand(300, 20000)}.dup(100);

  res    = Ringz.ar(lodriver + hidriver + thwack, freqs).mean;

  Out.ar(out, Pan2.ar(((res * 1) + (lodriver * 2) + thwack) * amp, pan));
SCLANG
  credit: "Based on the example at http://www.mcld.co.uk/cymbalsynthesis/ published 2008 by Dan Stowell",
  source: "https://github.com/supercollider-quarks/SynthDefPool",
)

end
end
end
