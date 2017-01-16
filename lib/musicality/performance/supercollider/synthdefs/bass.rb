module Musicality
module SuperCollider
module SynthDefs

MOOG_BASS = SynthDef.new(name: "moogbass", params: { :out => 0, :freq => 440, :amp => 0.8, :gate => 1,
    :cutoff => 1000, :gain => 2.0, :lagamount => 0.01, :pan => 0.0 },
  body: <<-SCLANG,
  var osc, filter, env, filterenv;

  osc = Mix(VarSaw.ar(freq.lag(lagamount)*[1.0,1.001,2.0],Rand(0.0,1.0)!3,Rand(0.5,0.75)!3,0.33));
  filterenv = EnvGen.ar(Env.adsr(0.2,0.0,1.0,0.2),gate,doneAction:2);
  filter =  MoogFF.ar(osc,cutoff*(1.0+(0.5*filterenv)),gain);
  env = EnvGen.ar(Env.adsr(0.001,0.3,0.9,0.2),gate,doneAction:2);

  Out.ar(out,Pan2.ar((0.7*filter+(0.3*filter.distort))*env*amp*1.5,pan));
SCLANG
  credit: <<-EOS,
Sound recipes from:
Mitchell Sigman (2011) Steal this Sound. Milwaukee, WI: Hal Leonard Books
adapted for SuperCollider and elaborated by Nick Collins (http://www.sussex.ac.uk/Users/nc81/index.html)
under GNU GPL 3  as per SuperCollider license
EOS
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

MOOG_BASS2 = SynthDef.new(name: "moogbass2", params: { :out => 0, :freq => 440, :amp => 0.8, :gate => 1,
    :attackTime => 0.2, :fenvamount => 0.5, :cutoff => 1000, :gain => 2.0, :pan => 0.0 },
  body: <<-SCLANG,
  var osc, filter, env, filterenv;

  //alternative: richer source
  osc = Mix(Pulse.ar(freq.lag(0.05)*[1.0,1.001,2.0],Rand(0.45,0.5)!3,0.33));
  filterenv = EnvGen.ar(Env.adsr(attackTime,0.0,1.0,0.2),gate,doneAction:2);
  filter =  MoogFF.ar(osc,cutoff*(1.0+(fenvamount*filterenv)),gain);
  env = EnvGen.ar(Env.adsr(0.001,0.3,0.9,0.2),gate,doneAction:2);

  Out.ar(out,Pan2.ar((0.7*filter+(0.3*filter.distort))*env*amp,pan));
SCLANG
  credit: <<-EOS,
Sound recipes from:
Mitchell Sigman (2011) Steal this Sound. Milwaukee, WI: Hal Leonard Books
adapted for SuperCollider and elaborated by Nick Collins (http://www.sussex.ac.uk/Users/nc81/index.html)
under GNU GPL 3  as per SuperCollider license
EOS
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

BASS_FOUNDATION = SynthDef.new(name: "bassfoundation", params: { :out => 0, :freq => 440, :amp => 0.8, :gate => 1,
    :cutoff => 1000, :rq => 0.5, :pan => 0.0 },
  body: <<-SCLANG,
  var osc, filter, env, filterenv;

  osc = Saw.ar(freq);
  filterenv = EnvGen.ar(Env.adsr(0.0,0.5,0.2,0.2),gate,doneAction:2);
  filter =  RLPF.ar(osc,cutoff*filterenv+100,rq);
  env = EnvGen.ar(Env.adsr(0.01,0.0,0.9,0.05),gate,doneAction:2);

  Out.ar(out,Pan2.ar(filter*env*amp*2,pan));
SCLANG
  credit: <<-EOS,
Sound recipes from:
Mitchell Sigman (2011) Steal this Sound. Milwaukee, WI: Hal Leonard Books
adapted for SuperCollider and elaborated by Nick Collins (http://www.sussex.ac.uk/Users/nc81/index.html)
under GNU GPL 3  as per SuperCollider license
EOS
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

BASS_HIGHEND = SynthDef.new(name: "basshighend", params: { :out => 0, :freq => 440, :amp => 0.8, :gate => 1,
    :cutoff => 3000, :rq => 0.1, :drive => 2.0, :pan => 0.0 },
  body: <<-SCLANG,
  var osc, filter, env, filterenv;
  var ab;

  //osc = Mix(VarSaw.ar(freq*[0.25,1,1.5],Rand(0.0,1.0)!3,0.9,[0.5,0.4,0.1]));
  osc = Mix(Saw.ar(freq*[0.25,1,1.5],[0.5,0.4,0.1]));
  //osc = Mix(DPW4Saw.ar(freq*[0.25,1,1.5],[0.5,0.4,0.1]));
  filterenv = EnvGen.ar(Env.adsr(0.0,0.5,0.2,0.2),gate,doneAction:2);
  filter =  RLPF.ar(osc,cutoff*filterenv+100,rq);

  //distortion
  //filter = filter.distort.softclip;

  ab = abs(filter);
  filter = (filter*(ab + drive)/(filter ** 2 + (drive - 1) * ab + 1));

  //remove low end
  filter = BLowShelf.ar(filter,300,1.0,-12);
  //dip at 1600Hz
  filter = BPeakEQ.ar(filter,1600,1.0,-6);

  env = EnvGen.ar(Env.adsr(0.01,0.0,0.9,0.05),gate,doneAction:2);

  Out.ar(out,Pan2.ar(filter*env*amp*2,pan));
SCLANG
  credit: <<-EOS,
Sound recipes from:
Mitchell Sigman (2011) Steal this Sound. Milwaukee, WI: Hal Leonard Books
adapted for SuperCollider and elaborated by Nick Collins (http://www.sussex.ac.uk/Users/nc81/index.html)
under GNU GPL 3  as per SuperCollider license
EOS
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

FAT_VELOCITY_BASS = SynthDef.new(name: "fatvelocitybass", params: { :out => 0, :freq => 440, :amp => 0.5,
    :gate => 1, :cutoff => 2000, :rq => 0.15, :lagTime => 0.01, :pan => 0.0 },
  body: <<-SCLANG,
  var lfo, osc, filter, env;

  var basefreq =  ((freq.lag(lagTime).cpsmidi)+[0,11.95,31.03]).midicps;
  osc = Saw.ar(basefreq,[0.5,0.4,0.1]); //+PinkNoise.ar(Line.kr(1.0,0,0.03));
  env = EnvGen.ar(Env.adsr(0.01,1.0,1.0,0.25),gate,doneAction:2);
  filter = BLowPass4.ar(osc,100+((amp.squared)*(freq+cutoff)),rq);

  Out.ar(out,Pan2.ar(Mix(filter)*env*amp*0.8,pan));
SCLANG
  credit: <<-EOS,
Sound recipes from:
Mitchell Sigman (2011) Steal this Sound. Milwaukee, WI: Hal Leonard Books
adapted for SuperCollider and elaborated by Nick Collins (http://www.sussex.ac.uk/Users/nc81/index.html)
under GNU GPL 3  as per SuperCollider license
EOS
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

BASS1 = SynthDef.new(name: "bass1", params: { :out => 0, :freq => 440, :gate => 1, :amp => 0.5, :slideTime => 0.17, :ffreq => 1100, :width => 0.15, :detune => 1.005, :preamp => 4 },
  body: <<-SCLANG,
    var sig, env;
  env = Env.adsr(0.01, 0.3, 0.4, 0.1);
    freq = Lag.kr(freq, slideTime);
    sig = Mix(VarSaw.ar([freq, freq * detune], 0, width, preamp)).distort;
  sig = sig * amp * EnvGen.kr(env, gate, doneAction: 2);
    sig = LPF.ar(sig, ffreq);
    Out.ar(out, sig ! 2)
SCLANG
  source: "From https://github.com/brunoruviaro/SynthDefs-for-Patterns",
)

CHORD_BASS = SynthDef.new(name: "chord_bass", params: { :out => 0, :amp => 0.5, :sustain => 0.1, :freq => 90, :filtfreq1 => 7000, :filtfreq2 => 1000, :releaseTime => 0.5, :reverb => 0.1,:rq => 0.99 },
  body: <<-SCLANG,
  var env, sound;
  env=EnvGen.ar(Env.perc(releaseTime:releaseTime),doneAction:2);
  sound=FreeVerb.ar(RLPF.ar(LFSaw.ar(freq,0,amp),Line.kr(filtfreq1, filtfreq2,0.1),rq), reverb, 0.2, 0.5);
  Out.ar(out,Pan2.ar(sound*env, 0.0))
SCLANG
  source: "https://github.com/willieavendano/SC-SynthDefs/blob/master/DrumMachines",
)

MY_BASS = SynthDef.new(name: "my_bass", params: { :out => 0, :amp => 1, :sustain => 0.3, :freq => 90, :filtfreq1 => 7000, :filtfreq2 => 1000, :releaseTime => 0.5, :reverb => 0.3, :rq => 0.99 },
  body: <<-SCLANG,
  var env, sound;
  env=EnvGen.ar(Env.perc(releaseTime:releaseTime),doneAction:2);
  sound=FreeVerb.ar(RLPF.ar(LFTri.ar(freq,0,amp*2),Line.kr(filtfreq1, filtfreq2,0.1),rq) ,reverb, 0.2 ,0.5);
  Out.ar(out,Pan2.ar(sound*env, 0.0))
SCLANG
  source: "https://github.com/willieavendano/SC-SynthDefs/blob/master/DrumMachines",
)

BASS2 = SynthDef.new(name: "bass2", params: { :out => 0, :freq => 440, :gate => 1, :amp => 1.0, :slideTime => 0.17, :ffreq => 1100, :width => 0.15, :detune => 1.005, :preamp => 4, :dur => 0.2, :length => 0.2 },
  body: <<-SCLANG,
  var sig,
    env = Env.adsr(0.01, 0.3, 0.4, 0.1);
  freq = Lag.kr(freq, slideTime);
  sig = Mix(VarSaw.ar([freq, freq * detune], 0, width, preamp)).distort * amp
    * EnvGen.kr(env, gate * dur * length , doneAction: 2);
  sig = LPF.ar(sig, ffreq);
  Out.ar(out, sig ! 2)
SCLANG
  source: "https://github.com/mtytel/supersongs/",
)

BASS_303 = SynthDef.new(name: "bass303", params: { :out => 0, :freq => 440, :gate => 1, :lpf => 1000, :res => 0.8, :width => 0.05, :amp => 1, :vol => 0.5 },
  body: <<-SCLANG,
  var sig, env;
  var sig2, env2;

  // ghetto 303
  env = Env.adsr(0.05, 2, 0, 0.3, 0.8, -12);
  sig = LFPulse.ar(freq, width: width) + Pulse.ar(freq, width: 0.9);
  sig = sig * EnvGen.ar(env, gate, amp, doneAction: 2);
  sig = RLPF.ar(sig, lpf, res);

  env2 = Env.adsr(0.03, 2, 0, 0.3, 0.8, -13);
  sig2 = LFPulse.ar(freq, width: width)  + Pulse.ar(freq, width: 0.9);
  sig2 = FreqShift.ar(sig2, 3);
  sig2 = sig2 * EnvGen.ar(env2, gate, amp, doneAction: 2);
  sig2 = RLPF.ar(sig2, lpf, res);


  Out.ar(out, [sig * vol, sig2 * vol]);

SCLANG
  source: "https://github.com/mattvears/supercollider-stuff",
)

BASS4 = SynthDef.new(name: "bass4", params: { :out => 0, :gate => 1, :freq => 440 },
  body: <<-SCLANG,
  var aEnv, fEnv, osc, flt;
  aEnv = EnvGen.kr(Env.asr(0, 1, 1), gate, doneAction: 2);
  fEnv = EnvGen.kr(Env.perc(0, 3), levelScale: 6000);
  osc = Mix([Saw.ar(freq * [1, 1.005]), Pulse.ar(freq / 2, 0.5)]);
  flt = LPF.ar(osc, fEnv + 100, aEnv);
  Out.ar(out, flt);
SCLANG
  credit: "From the Kraftwerk 'Spacelab' example in SuperCollider/examples by jy",
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

end
end
end
