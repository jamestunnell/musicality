module Musicality
module SuperCollider
module SynthDefs

CHEAP_PIANO = SynthDef.new(name: "cheappiano", params: { :out => 0, :freq => 440, :amp => 1, :dur => 1, :gate => 1, :pan => 0 },
  body: <<-SCLANG,
  var sig, in, n = 6, max = 0.04, min = 0.01, delay, pitch, detune, hammer;
  freq = freq.cpsmidi;
  hammer = Decay2.ar(Impulse.ar(0.001), 0.008, 0.04, LFNoise2.ar([2000,4000].asSpec.map(amp), 0.25));
  sig = Mix.ar(Array.fill(3, { arg i;
      detune = #[-0.04, 0, 0.03].at(i);
      delay = (1/(freq + detune).midicps);
      CombL.ar(hammer, delay, delay, 50 * amp)
    }) );

  sig = HPF.ar(sig,50) * EnvGen.ar(Env.perc(0.0001,dur, amp * 4, -1), gate: gate, doneAction:2);
  Out.ar(out, Pan2.ar(sig, pan));
SCLANG
  credit: "based on something posted 2008-06-17 by jeff, based on an old example by james mcc",
  source: "https://github.com/supercollider-quarks/SynthDefPool",
)

EVERYTHING_RHODES = SynthDef.new(name: "everythingrhodes", params: { :out => 0, :freq => 440, :amp => 0.1, :gate => 1,
    :lforate => 1.85, :lfowidth => 0.5, :cutoff => 2000, :rq => 0.2, :pan => 0.0 },
  body: <<-SCLANG,
  var pulse, filter, env;

  pulse = Pulse.ar(freq*[1,33.5.midiratio],[0.2,0.1],[0.7,0.3]);
  env = EnvGen.ar(Env.adsr(0.0,1.0,0.8,3.0),gate,doneAction:2);
  //keyboard tracking filter cutoff
  filter = BLowPass4.ar(pulse,(cutoff*(env.squared))+200+freq,rq);

  Out.ar(out,Pan2.ar(Mix(filter)*env*amp,pan));
SCLANG
  credit: <<-EOS,
Sound recipes from:
Mitchell Sigman (2011) Steal this Sound. Milwaukee, WI: Hal Leonard Books
adapted for SuperCollider and elaborated by Nick Collins (http://www.sussex.ac.uk/Users/nc81/index.html)
under GNU GPL 3  as per SuperCollider license
EOS
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

end
end
end
