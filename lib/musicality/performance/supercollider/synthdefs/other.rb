module Musicality
module SuperCollider
module SynthDefs

AXEL = DEFAULT = SynthDef.new(name: "axel", params: { :freq => 440, :lpfreq => 12000, :rq => 0.2, :gate => 1, :out => 0 },
  body: <<-SCLANG,
  var chorus = LFNoise2.ar(1).range(0.99, 1.01);
  var saw1 = LFSaw.ar(freq * chorus, 0, 0.1);
  var saw2 = LFSaw.ar((freq.cpsmidi - 0.1).midicps * chorus, 0, 0.1);
  var tri = LFTri.ar(freq * chorus, 0, 0.1);
  var mix = Mix([saw1, saw2, tri]);
  var lpf = RLPF.ar(mix, lpfreq, rq);
  var env = EnvGen.ar(Env.adsr(0.3, 0.6, 0.5, 0.25), gate, doneAction: 2);
  Out.ar(out, Pan2.ar(lpf * env, 0));
SCLANG
  credit: "By Arthur Carabott, based on Sound on Sound article",
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

BRASS = SynthDef.new(name: "brass", params: { :freq => 220, :detune1 => 1, :detune2 => 0.5, :ffreq => 12000, :rq => 0.4,
    :pan => 0, :gate => 1, :out => 0 },
  body: <<-SCLANG,
  var sig, env, fenv;

  sig = Mix([freq, freq - detune1, freq + detune2, freq / 2].collect {|freq|
    LFSaw.ar(freq);
  });
  fenv = EnvGen.kr(Env([ffreq, 0], [0.06], \\sin));
  sig = RHPF.ar(sig, fenv, rq);
  env = EnvGen.ar(Env.asr(0.01, 1, 0.1), gate, doneAction:2);

  Out.ar(out, Pan2.ar(sig * env * 0.2, pan));
SCLANG
  credit: "Based on Sound on Sound Synth Secrets Part 25 by Arthur Carabott",
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

RES = SynthDef.new(name: "res", params: { :out => 0, :gate => 1, :freq => 440, :ffreq => 1500 },
  body: <<-SCLANG,
  var aEnv, osc, flt;
  aEnv = EnvGen.kr(Env.perc(0, 0.7), gate, doneAction: 2);
  osc = Mix([Saw.ar(freq), Pulse.ar(freq / 2, 0.5)]);
  flt = RLPF.ar(osc, ffreq, 0.1, aEnv);
  Out.ar(out, Pan2.ar(flt, 0));
SCLANG
  credit: "From the Kraftwerk 'Spacelab' example in SuperCollider/examples by jy",
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

POLY2 = SynthDef.new(name: "poly2", params: { :out => 0, :gate => 1, :freq => 440 },
  body: <<-SCLANG,
  var aEnv, fEnv, osc1, osc2, flt;
  aEnv = EnvGen.kr(Env.asr(0.2, 1, 0.1), gate, doneAction: 2);
  fEnv = EnvGen.kr(Env.asr(7, 1, 0.2), levelScale: 12000);
  osc1 = Pulse.ar(freq * [1, 1.007], LFCub.kr(2, 0, 0.3, 0.5));
  osc2 = Pulse.ar(freq / 2, 0.3);
  flt = RLPF.ar(osc1 + osc2, fEnv, 0.9, aEnv);
  Out.ar(out, flt);
SCLANG
  credit: "From the Kraftwerk 'Spacelab' example in SuperCollider/examples by jy",
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

SOLO = SynthDef.new(name: "solo", params: { :out => 0, :gate => 1, :freq => 440 },
  body: <<-SCLANG,
  var aEnv, fEnv, osc, flt;
  aEnv = EnvGen.kr(Env.asr(0.2, 1, 2), gate);
  fEnv = EnvGen.kr(Env.adsr(0.4, 1.2, 0.7, 2), gate, 800);
  osc = Saw.ar(Lag.kr(freq, 0.1) * [1, 1.005]);
  flt = LPF.ar(osc, fEnv + 600, aEnv);
  Out.ar(out, flt);
SCLANG
  credit: "From the Kraftwerk 'Spacelab' example in SuperCollider/examples by jy",
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

STRING = SynthDef.new(name: "string", params: { :out => 0, :gate => 1, :freq => 1000 },
  body: <<-SCLANG,
  var aEnv, osc, flt;
  aEnv = EnvGen.kr(Env.asr(0.2, 1, 0.5), gate, doneAction: 2);
  osc = Saw.ar([
    LFCub.kr(0.3, Rand(0, 1), freq * 0.003, freq),
    freq,
    LFCub.kr(0.7, Rand(0, 1), freq * 0.001, freq)
  ]);
  flt = LPF.ar(osc, 1500, aEnv);
  Out.ar(out, flt);
SCLANG
  credit: "From the Kraftwerk 'Spacelab' example in SuperCollider/examples by jy",
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

ESM = SynthDef.new(name: "esm", params: { :freq => 440, :mix => 0.5, :glide => 0, :cutoff => 20000, :rq => 1, :fdec => 0, :fint => 1,
  :vel => 1, :fvel => 1, :t_gate => 1, :vdec => 1, :vvel => 0, :od => 0, :mul => 0.1, :pan => 0, :out => 0 },
  body: <<-SCLANG,
  var sig, saw, rect, fstart, fenv, vstart, venv;

  freq = freq.lag(glide);

  // oscillators
  saw = LFSaw.ar(freq, 0, 1);
  rect = LFPulse.ar(freq, 0, 0.5, 1);
  sig = Mix([saw * (1-mix), rect * mix]);

  // filter
  fstart = vel.linlin(0, fvel, 0, fint).linexp(0, 1, cutoff, 20000);
  fenv = EnvGen.kr(Env([fstart, fstart, cutoff], [0.001, fdec]), t_gate);
  sig = LPF.ar(sig, fenv, rq);

  // volume env
  vstart = vel.linlin(0, vvel.max(10e-1), 0, 1);
  venv = EnvGen.ar(Env([vstart, vstart, 0], [0.01, vdec], \cub), t_gate);
  sig = sig * venv;

  // distortion
  sig = sig * od.linlin(0, 1, 1, 100).clip2(mul);

  Out.ar(out, Pan2.ar(sig, pan));
SCLANG
  credit: "Emulations of two synths from Logic Pro X, by Arthur Carabott",
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

ROCKIT = SynthDef.new(name: "rockit", params: { :freq => 440, :detune => 2, :gate => 1, :out => 0 },
  body: <<-SCLANG,
  var osc1, osc2, pwm, mix, env;

  // envelope for pulse width
  pwm = EnvGen.kr(Env([0, 0.5, 0], [0.1, 0.3], ['lin', -1]));

  // two oscillators, slightly detuned
  osc1 = LFPulse.ar(freq, 0, pwm);
  osc2 = LFPulse.ar(freq - detune, 0, pwm);

  // mixdown  oscillators
  mix = Mix([osc1, osc2]);

  // amplitude envelope
  env = EnvGen.ar(Env.asr(0.001, 1, 0.05), gate, doneAction:2);
  mix = mix * env;

  Out.ar(out, Pan2.ar(mix, 0));
SCLANG
  credit: "From the 'Emulating Video Game Sounds' recipe, page 78 of 'Steal This Sound' by Mitchell Sigman, Adapted by Arthur Carabott",
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

PROPHET5_STRINGS = SynthDef.new(name: "prophet5pwmstrings", params: { :out => 0, :freq => 440, :amp => 0.8,
    :gate => 1, :lforate => 3, :lfowidth => 0.1, :cutoff => 12000, :rq => 0.5, :pan => 0.0 },
  body: <<-SCLANG,
  var lfo, pulse, filter, env;

  lfo = LFTri.kr(lforate*[1,1.01],Rand(0,2.0)!2);
  pulse = Pulse.ar(freq*[1,1.01],lfo*lfowidth+0.5);
  filter = RLPF.ar(pulse,cutoff,rq);
  env = EnvGen.ar(Env.adsr(0.01,0.0,1.0,0.5),gate,doneAction:2);

  Out.ar(out,Pan2.ar(Mix(filter)*env*amp*0.5,pan));
SCLANG
  credit: <<-EOS,
Sound recipes from:
Mitchell Sigman (2011) Steal this Sound. Milwaukee, WI: Hal Leonard Books
adapted for SuperCollider and elaborated by Nick Collins (http://www.sussex.ac.uk/Users/nc81/index.html)
under GNU GPL 3  as per SuperCollider license
EOS
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

OSC_WOBBLE = SynthDef.new(name: "singleoscillatorwobble", params: { :out => 0, :freq => 440, :amp => 0.8,
    :gate => 1, :lforate => 10, :lfowidth => 0.5, :cutoff => 12000, :rq => 0.5, :pan => 0.0 },
  body: <<-SCLANG,
  var lfo, pulse, filter, env;

  lfo = LFTri.kr(lforate,Rand(0,2.0)!2);
  pulse = Pulse.ar(freq*(1.0+(lfowidth*lfo)),0.5);
  filter = RLPF.ar(pulse,cutoff,rq);
  env = EnvGen.ar(Env.adsr(0.01,0.0,1.0,0.5),gate,doneAction:2);

  Out.ar(out,Pan2.ar(filter*env*amp*0.5,pan));
SCLANG
  credit: <<-EOS,
Sound recipes from:
Mitchell Sigman (2011) Steal this Sound. Milwaukee, WI: Hal Leonard Books
adapted for SuperCollider and elaborated by Nick Collins (http://www.sussex.ac.uk/Users/nc81/index.html)
under GNU GPL 3  as per SuperCollider license
EOS
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

TRI_BELLS = SynthDef.new(name:"trianglewavebells", params: { :out => 0, :freq => 440, :amp => 0.8, :gate => 1,
    :lforate => 10, :lfowidth => 0.0, :cutoff => 100, :rq => 0.5, :pan => 0.0 },
  body: <<-SCLANG,
  var osc1, osc2, vibrato, filter, env;

  vibrato = SinOsc.ar(lforate,Rand(0,2.0));
  osc1 = Saw.ar(freq*(1.0+(lfowidth*vibrato)),0.75);
  //Saw a bit rough, possibly slighter smoother:
  //osc1 = DPW4Saw.ar(freq*(1.0+(lfowidth*vibrato)),0.5);
  osc2 = Mix(LFTri.ar((freq.cpsmidi+[11.9,12.1]).midicps));
  //filter = (osc1+(osc2*0.5))*0.5; //no filter version
  filter = RHPF.ar((osc1+(osc2*0.5))*0.5,cutoff,rq);
  env = EnvGen.ar(Env.adsr(0.01,0.1,1.0,0.5),gate,doneAction:2);

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

LASER_BEAM = SynthDef.new(name: "laserbeam", params: { :out => 0, :freq => 440, :amp => 0.8, :attackTime => 0.04, :gate => 1, :pan => 0.0 },
  body: <<-SCLANG,
  var osc1, freqenv, env;

  freqenv = EnvGen.ar(Env([4,0.5,1,1],[attackTime,0.01,1.0]));

  osc1 = LFTri.ar(freq*freqenv);

  env = EnvGen.ar(Env.adsr(0.01,0.0,1.0,0.1),gate,doneAction:2);
  //no gate, fixed envelope size
  //env = EnvGen.ar(Env([0,1,0.5,0.0],[0.02,0.2,0.1]),doneAction:2);

  Out.ar(out,Pan2.ar(osc1*env*amp,pan));
SCLANG
  credit: <<-EOS,
Sound recipes from:
Mitchell Sigman (2011) Steal this Sound. Milwaukee, WI: Hal Leonard Books
adapted for SuperCollider and elaborated by Nick Collins (http://www.sussex.ac.uk/Users/nc81/index.html)
under GNU GPL 3  as per SuperCollider license
EOS
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

PLASTICKY_STRINGS = SynthDef.new(name: "plastickystrings", params: { :out => 0, :freq => 440, :amp => 0.8, :gate => 1,
    :lforate => 5900, :lfowidth => 0.01, :cutoff => 12000, :rq => 0.5, :pan => 0.0 },
  body: <<-SCLANG,
  var lfo, saw, filter, env;

  lfo = LFTri.ar(lforate,Rand(0,2.0));
  saw = Saw.ar(freq*(1.0+(lfowidth*lfo)),0.5);
  //filter = BBandPass.ar(saw,freq,4);
  filter = BHiPass.ar(saw,freq,rq);   //or using cutoff
  env = EnvGen.ar(Env.adsr(0.4,0.0,1.0,1.0),gate,doneAction:2);

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

WINWOOD_LEAD = SynthDef.new(name: "winwoodlead", params: { :out => 0, :freq => 440, :amp => 0.8, :gate => 1,
    :cutoff => 8000, :rq => 0.8, :lfowidth => 0.01, :lforate => 8, :lagamount => 0.01, :pan => 0.0 },
  body: <<-SCLANG,
  var pulse, filter, env, lfo;

  lfo = LFTri.kr(lforate,Rand(0,2.0)!2);
  pulse = Mix(Pulse.ar((freq.lag(lagamount))*[1,1.001]*(1.0+(lfowidth*lfo)),[0.2,0.19]))*0.5;
  filter =  RLPF.ar(pulse,cutoff,rq);
  //remove low end
  filter = BLowShelf.ar(filter,351,1.0,-9);
  env = EnvGen.ar(Env.adsr(0.01,0.0,0.9,0.05),gate,doneAction:2);

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

SITUATION_SYNTH = SynthDef.new(name: "situationsynth", params: { :out => 0, :freq => 440, :amp => 0.1, :gate => 1,
    :cutoff => 8000, :rq => 0.8, :lfowidth => 0.001, :lforate => 3.3, :pan => -0.1 },
  body: <<-SCLANG,
  var pulse, filter, env, filterenv, lfo;

  lfo = LFTri.kr(lforate,Rand(0,2.0)!2);
  pulse = Mix(Pulse.ar((((freq.cpsmidi)+[0,0.14])+(lfo*lfowidth)).midicps,[0.5,0.51]+(lfowidth*lfo)))*0.5;
  filterenv = EnvGen.ar(Env([0.0,1.0,0.3,0.0],[0.005,0.57,0.1],-3));
  filter =  RLPF.ar(pulse,100+(filterenv*cutoff),rq);
  env = EnvGen.ar(Env.adsr(0.002,0.57,1.0,0.3),gate,doneAction:2);

  Out.ar(out,Pan2.ar(filter*env*amp,pan));
SCLANG
)

RES_SQUARES = SynthDef.new(name: "ressquares", params: { :out => 0, :freq => 440, :amp => 0.1, :gate => 1,
    :cutoff => 8000, :rq => 0.8, :pan => -0.1 },
  body: <<-SCLANG,
  var pulse, filter, env;

  //2 cents detune for second oscillator
  pulse = Mix(Pulse.ar( ((freq.cpsmidi)+[0,0.02]).midicps, 0.5))*0.5;
  filter =  BLowPass.ar(pulse,100+cutoff,rq);
  env = EnvGen.ar(Env.adsr(0.002,0.1,1.0,0.2),gate,doneAction:2);

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

TONEWHEEL_TWO = SynthDef.new(name: "tonewheeltwo", params: { :out => 0, :freq => 440, :amp => 0.1, :gate => 1,
    :lforate => 4.85, :lfowidth => 0.1, :cutoff => 5000, :rq => 0.25, :pan => 0.0 },
  body: <<-SCLANG,
  //tone wheel organ emulation via two oscillators pp. 50-51

  var lfo, pulse, filter, env;

  lfo = LFTri.kr(lforate*[1,1.01],Rand(0,2.0)!2);
  pulse = Pulse.ar( (((freq*[1,3]).cpsmidi) + (lfo*lfowidth)).midicps,[0.5,0.51],[0.4,0.6]);
  env = EnvGen.ar(Env.adsr(0.0,0.0,1.0,0.1),gate,doneAction:2);
  filter = BLowPass4.ar(pulse,cutoff,rq);
  filter = BPeakEQ.ar(filter,500,1.0,3);

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

SPACE_THEREMIN = SynthDef.new(name: "spacetheremin", params: { :out => 0, :freq => 440, :amp => 0.1,
    :gate => 1, :lforate => 6, :lfowidth => 0.5, :cutoff => 4000, :rq => 0.25, :lagTime => 0.1, :pan => 0.0 },
  body: <<-SCLANG,
  var lfo, osc, filter, env;

  lfo = LFTri.kr(lforate+(LFNoise1.kr(5,0.3,0.3)),Rand(0,2.0));
  osc = Saw.ar((freq.lag(lagTime).cpsmidi+(lfo*lfowidth)).midicps,0.5);
  filter = BLowPass4.ar(osc,cutoff.lag(lagTime*4),rq);
  env = EnvGen.ar(Env.adsr(0.6,0.0,1.0,0.05),gate,doneAction:2);

  Out.ar(out,Pan2.ar(filter*env*amp.lag(lagTime*4),pan));
SCLANG
  credit: <<-EOS,
Sound recipes from:
Mitchell Sigman (2011) Steal this Sound. Milwaukee, WI: Hal Leonard Books
adapted for SuperCollider and elaborated by Nick Collins (http://www.sussex.ac.uk/Users/nc81/index.html)
under GNU GPL 3  as per SuperCollider license
EOS
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

PMC_ROTALE = SynthDef.new(name: "PMCrotale", params: { :out => 0, :freq => 261, :tone => 3, :art => 1, :amp => 0.8, :pan => 0 },
  body: <<-SCLANG,
  var env, mod, sig;

  env = Env.perc(0, art);
  mod = 5 + (1/IRand(2, 6));

  sig = PMOsc.ar(freq, mod*freq,
    pmindex: EnvGen.kr(env, timeScale: art, levelScale: tone),
    mul: EnvGen.kr(env, timeScale: art, levelScale: 0.3));

  sig = Pan2.ar(sig, pan);

  sig = sig * EnvGen.kr(env, timeScale: 1.3*art,
    levelScale: Rand(0.1, 0.5), doneAction:2);
  Out.ar(out, sig*amp);
SCLANG
  source: "From https://github.com/brunoruviaro/SynthDefs-for-Patterns",
)

KRAFTY_SNR = SynthDef.new(name: "kraftySnr", params: { :out => 0, :amp => 1, :freq => 2000, :rq => 3, :decay => 0.3, :pan => 0 },
  body: <<-SCLANG,
  var sig = PinkNoise.ar(amp),
  env = EnvGen.kr(Env.perc(0.01, decay), doneAction: 2);
  sig = BPF.ar(sig, freq, rq, env);
  Out.ar(out, Pan2.ar(sig, pan))
SCLANG
  source: "From https://github.com/brunoruviaro/SynthDefs-for-Patterns",
)

SILLY_VOICE = SynthDef.new(name: "sillyVoice", params: { :out => 0, :freq => 220, :amp => 0.5, :vibratoSpeed => 6, :vibratoDepth => 4, :vowel => 0, :att => 0.01, :rel => 0.1, :lag => 1, :gate => 1 },
  body: <<-SCLANG,
  var in, vibrato, env, va, ve, vi, vo, vu, snd;

  vibrato = SinOsc.kr(vibratoSpeed, mul: vibratoDepth);
  in = Saw.ar(Lag.kr(freq, lag) + vibrato);
  env = EnvGen.kr(Env.asr(att, 1, rel), gate, doneAction: 2);

  va = BBandPass.ar(
    in: in,
    freq: [ 600, 1040, 2250, 2450, 2750 ],
    bw: [ 0.1, 0.067307692307692, 0.048888888888889, 0.048979591836735, 0.047272727272727 ],
    mul: [ 1, 0.44668359215096, 0.35481338923358, 0.35481338923358, 0.1 ]);

  ve = BBandPass.ar(
    in: in,
    freq: [ 400, 1620, 2400, 2800, 3100 ] ,
    bw: [ 0.1, 0.049382716049383, 0.041666666666667, 0.042857142857143, 0.038709677419355 ],
    mul: [ 1, 0.25118864315096, 0.35481338923358, 0.25118864315096, 0.12589254117942 ]);

  vi = BBandPass.ar(
    in: in,
    freq: [ 250, 1750, 2600, 3050, 3340 ] ,
    bw: [ 0.24, 0.051428571428571, 0.038461538461538, 0.039344262295082, 0.035928143712575 ],
    mul: [ 1, 0.031622776601684, 0.15848931924611, 0.079432823472428, 0.03981071705535 ] );

  vo = BBandPass.ar(
    in: in,
    freq:[ 400, 750, 2400, 2600, 2900 ] ,
    bw: [ 0.1, 0.10666666666667, 0.041666666666667, 0.046153846153846, 0.041379310344828 ],
    mul: [ 1, 0.28183829312645, 0.089125093813375, 0.1, 0.01 ]);

  vu = BBandPass.ar(
    in: in,
    freq: [ 350, 600, 2400, 2675, 2950 ],
    bw: [ 0.11428571428571, 0.13333333333333, 0.041666666666667, 0.044859813084112, 0.040677966101695 ],
    mul: [ 1, 0.1, 0.025118864315096, 0.03981071705535, 0.015848931924611 ]);

  snd = SelectX.ar(Lag.kr(vowel, lag), [va, ve, vi, vo, vu]);
  snd = Mix.new(snd);
  Out.ar(out, snd!2 * env * amp);
SCLANG
  source: "From https://github.com/brunoruviaro/SynthDefs-for-Patterns",
)

PLUCKING = SynthDef.new(name: "plucking", params: { :out => 0, :amp => 0.1, :freq => 440, :decay => 5, :coef => 0.1 },
  body: <<-SCLANG,
var env, snd;
env = EnvGen.kr(Env.linen(0, decay, 0), doneAction: 2);
snd = Pluck.ar(
        in: WhiteNoise.ar(amp),
        trig: Impulse.kr(0),

        maxdelaytime: 0.1,
        delaytime: freq.reciprocal,
        decaytime: decay,
        coef: coef);
    Out.ar(out, [snd, snd]);
SCLANG
  source: "From https://github.com/brunoruviaro/SynthDefs-for-Patterns",
)

TRIG_DEMO = SynthDef.new(name: "trig_demo", params: { :out => 0, :freq => 440, :gate => 1, :t_trig => 1 },
  body: <<-SCLANG,
    var env, sig;
  env = Decay2.kr(t_trig, 0.01, 0.1);
    sig = SinOsc.ar(freq, 0, env);
  sig = sig * Linen.kr(gate, 0.01, 0.1, 0.1, doneAction: 2);
    Out.ar(out, sig ! 2)
SCLANG
  source: "From https://github.com/brunoruviaro/SynthDefs-for-Patterns",
)


SINE_WLFO = SynthDef.new(name: "sineWlfo", params: { :out => 0, :rate => 0.5, :freqlo => 150, :freqhi => 300, :amp => 0.1 },
  body: <<-SCLANG,
  var sig, lfo, rms;
  lfo = SinOsc.kr(rate).range(freqlo, freqhi);
  sig = SinOsc.ar(lfo);
  sig = sig*amp.dbamp;
  Out.ar(out, sig)
SCLANG
  source: "From https://github.com/elosine/synthdefs",
)

NOISE_BURST = SynthDef.new(name: "noiseBurst", params: { :out => 0, :rate => 1.0, :atk => 0.03, :decay => 0.75, :amp => 0 },
  body: <<-SCLANG,
    var sig;
    sig = PinkNoise.ar(0.5) * Decay2.ar( Impulse.ar(rate), atk, decay );
    sig = sig*amp.dbamp;
    Out.ar(out, sig)
SCLANG
  source: "From https://github.com/elosine/synthdefs",
)

ACID_OTO_309 = SynthDef.new(name: "acid_oto309", params: { :out => 0, :gate => 1, :freq => 440, :amp => 0.1, :pan => 0 },
  body: <<-SCLANG,
  var env1, env2, son, pitch;
  pitch = freq.cpsmidi;
  pitch = Lag.kr(pitch, 0.12 * (1-Trig.kr(gate, 0.001)) * gate);
  env1 = EnvGen.ar(Env.new([0, 1.0, 0, 0], [0.001, 2.0, 0.04], [0, -4, -4], 2), gate, amp);
  env2 = EnvGen.ar(Env.adsr(0.001, 0.8, 0, 0.8, 70, -4), gate);
  son = LFPulse.ar(pitch.midicps, 0.0, 0.51, 2, -1);

  son = RLPF.ar(son, (pitch + env2).midicps, 0.3);
  son = son * env1;

  Out.ar(out, Pan2.ar(son, pan));
SCLANG
  credit: "from 08091500Acid309 by_otophilia",
  source: "https://github.com/supercollider-quarks/SynthDefPool",
)

APAD_MH = SynthDef.new(name: "apad_mh", params: { :freq => 880, :amp => 0.5, :attack => 0.4, :decay => 0.5, :sustain => 0.8, :release => 1.0, :gate => 1, :out => 0 },
  body: <<-SCLANG,
  var env,sig,mod1,mod2,mod3;
  env=EnvGen.kr(Env.adsr(attack,decay,sustain,release),gate,levelScale:amp,doneAction:2);
  mod1=SinOsc.kr(6).range(freq*0.99,freq*1.01);
  mod2=LFNoise2.kr(1).range(0.2,1);
  mod3=SinOsc.kr(rrand(4.0,6.0)).range(0.5,1);
  sig=SinOsc.ar([freq,mod1],0,env).distort;
  sig=sig*mod2*mod3;
  Out.ar(out,sig);
SCLANG
  credit: "A simple sustained sound with vibrato --Mike Hairston",
  source: "https://github.com/supercollider-quarks/SynthDefPool",
)

CS80_LEAD_MH = SynthDef.new(name: "cs80lead_mh", params: { :freq => 880, :amp => 0.5, :att => 0.75, :decay => 0.5,
    :sus => 0.8, :rel => 1.0, :fatt => 0.75, :fdecay => 0.5, :fsus => 0.8, :frel => 1.0, :cutoff => 200, :pan => 0,
    :dtune => 0.002, :vibrate => 4, :vibdepth => 0.015, :gate => 1, :ratio => 1,:out => 0 },
  body: <<-SCLANG,
  var env,fenv,vib,ffreq,sig;
  cutoff=1000;
  env=EnvGen.kr(Env.adsr(att,decay,sus,rel),gate,levelScale:1,doneAction:2);
  fenv=EnvGen.kr(Env.adsr(fatt,fdecay,fsus,frel,curve:2),gate,levelScale:1,doneAction:2);
  vib=SinOsc.kr(vibrate).range(-1*vibdepth,vibdepth)+1;
  freq=Line.kr(freq,freq*ratio,5);
  freq=freq*vib;
  sig=Mix.ar(Saw.ar([freq,freq*(1+dtune)],mul:env*amp));
  // keep this below nyquist!!
  ffreq=max(fenv*freq*12,cutoff)+100;
  sig=LPF.ar(sig,ffreq);
  Out.ar(out, Pan2.ar(sig,pan) );
SCLANG
  credit: "Vangelis/Blade Runner lead sound, based on tutorial by meastempo @ http://www.youtube.com/watch?v=Fne0oIEv-WI",
  source: "https://github.com/supercollider-quarks/SynthDefPool",
)

PING_MH = SynthDef.new(name: "ping_mh", params: { :freq => 440,:amp => 0.2,:dur => 1,:attack => 0.001,:pan => 0,:out => 0 },
  body: <<-SCLANG,
    var sig,freq2;
    freq=freq*rrand(1,1.01);
    freq2=freq*rrand(1,1.01);
    e=EnvGen.ar(Env.perc(attack,dur,curve:-4),doneAction:2);
    sig=SinOsc.ar([freq,freq2],0,amp*e);
    sig=Pan2.ar(sig,pan);
    Out.ar(out,sig)
SCLANG
  credit: "Your basic percussive synth instrument, a good default sound for testing patterns, etc.",
  source: "https://github.com/supercollider-quarks/SynthDefPool",
)

SOS_BELL = SynthDef.new(name: "sos_bell", params: { :freq => 440, :out => 0, :amp => 0.1, :pan => 0 },
  body: <<-SCLANG,
  var son, strike, hum;

  // Stretched harmonic series
  son = SinOsc.ar(#[2, 3, 4.1, 5.43, 6.8, 8.21] * freq, 0,
     #[1, 0.9, 0.8, 0.7, 0.6, 0.5] * 0.1);

  son = son * EnvGen.ar(Env.new([0,1,0.3, 0.2, 0], [0, 0.3, 0.3, 0.3]));

  // A bit of FM adds 'warble'
  son = son * LFTri.ar({Rand(1.0, 1.8)}.dup(6), 1, 0.3, 0.7);

  // Mix down the partials in the main sound
  son = son.mean;

  strike = SinOsc.ar(LFNoise1.ar(freq * 36, 100, freq*8), 1, 0.1) *
      EnvGen.ar(Env.new([0,1,0.2, 0.1, 0], [0, 0.01, 0, 0.04]));

  hum = SinOsc.ar([freq*1.01, freq*0.47], 0, EnvGen.ar(Env.new([0,0.05,0.05,0], [0.5,0.5,1]), doneAction:2)).mean;

  Out.ar(out, Pan2.ar((son + strike + hum) * 4 * amp, pan));
SCLANG
  credit: "by dan stowell. based on a sound-on-sound 'synth secrets' tutorial",
  source: "https://github.com/supercollider-quarks/SynthDefPool",
)

KRGN_GEN_FMDEVIL = SynthDef.new(name: "krgn_gen_fmdevil", params: { :out => 0, :freq => 440, :amp => 1.0, :index => 3, :detune => 1.02, :gate => 1 },
  body: <<-SCLANG,
  var mod1, mod2, mod3, car, idx, env;
  env = EnvGen.ar(Env.adsr(0,0.4,0.3,0.2),gate: gate, levelScale: amp, doneAction: 2);
  idx = EnvGen.ar(Env.adsr(0,0.8,0.0,0.8),gate: gate, levelScale: index);
  mod1 = SinOsc.ar((freq / 12) * 2, LocalIn.ar(2), idx);
  mod2 = SinOsc.ar((freq / 12) * 6, mod1, idx);
  mod3 = SinOsc.ar([(freq / 12) * (9 * detune.neg), (freq / 12) * (9*detune)], mod2, idx);
  LocalOut.ar( mod3 * 0.25);
  car = SinOsc.ar(freq, mod3, env);
  Out.ar(out!2,car)
SCLANG
  source: "https://github.com/mtytel/supersongs/",
)

DROPLET = SynthDef.new(name: "droplet", params: { :amp => 0.2, :out => 0, :freq => 3000, :dur => 1, :rate => 1 },
  body: <<-SCLANG,
  /**
  * No.2 - Droplet
  *
  * pitch envelope-based synth
  */

  var sound,volEnv,pitchEnv, gate;
  gate = Pulse.kr(rate);
  pitchEnv=EnvGen.ar(Env.new([0.9,0.7,1,1],[0.06,0.05,0.89]*dur,\exponential), gate);
  volEnv=EnvGen.ar(Env.new([0,1,0.8,0.0],[0.2,0.05,0.75]*dur),gate);
  sound=SinOsc.ar(freq*pitchEnv,mul:volEnv);
  Out.ar(out, Pan2.ar(sound) * amp);
SCLANG
  source: "https://github.com/johncburnett/Matrix",
)

PHASE_MOD = SynthDef.new(name: "phaseMod", params: { :amp => 0.2, :out => 0, :freq => 30, :gate => 1 },
  body: <<-SCLANG,
  /**
  * No.4 - phaseMod
  *
  * Phase modulation
  */

  var fund, oscA, oscB, pm, env, sig;
  fund = freq;
  oscA = PMOsc.ar(fund, fund / 2.05, 2pi * 0.1);
  oscB = SinOsc.ar(fund / 2.01, oscA * 2pi * 0.5);
  pm = SinOsc.ar(fund / 2.02, oscB * 2pi * 0.8);
  env = EnvGen.ar(Env.adsr, gate: gate);
  sig = env * pm;
  Out.ar(out, (amp*sig)!2);
SCLANG
  source: "https://github.com/johncburnett/Matrix",
)

NOISE = SynthDef.new(name: "noise", params: { :amp => 0.2, :out => 0 },
  body: <<-SCLANG,
  /**
  * No.5 - noise
  *
  */

  var noise = HenonN.ar(SampleRate.ir/4, Rand(1,1.4), Rand(0,0.3)) * 0.2;
  Out.ar(out, noise!2 * amp);
SCLANG
  source: "https://github.com/johncburnett/Matrix",
)

NS_STATIC = SynthDef.new(name: "nsStatic", params: { :amp => 0.2, :out => 0,:mix => 0.9 },
  body: <<-SCLANG,
  /**
  * No.6 - nsSTatic
  *
  */

  var sound, sound2, stereo, dummy, dummy2;
  dummy = Rand(0.2, 2.01);
  //dummy2 = 0.01*Rand(0, 100);
  dummy2 = mix;
  sound = Crackle.ar(dummy, 0.5, 0.5);//chaosParam val ~0.95 -> ~2.05
  sound2 = PitchShift.ar(sound, 0.2, 0.249, 0.02,2);
  mix = sound*dummy2 + (sound2*(1.0+(-1*dummy2)));
  stereo = Limiter.ar(Pan2.ar(mix), 0.5);
  Out.ar(out,stereo*amp);
SCLANG
  source: "https://github.com/johncburnett/Matrix",
)

POOM = SynthDef.new(name: "poom", params: { :out => 0, :freq => 400, :level => 0.1 },
  body: <<-SCLANG,
  var env       = Env.perc(level: level);
  var envgen      = EnvGen.kr(env, doneAction: 2);
  var sin       = SinOsc.ar([freq, freq + 0.1], mul: envgen);
  var sin2      = SinOsc.ar([freq, freq + 0.1] * 17, mul: envgen / 17);
  Out.ar(out, sin + sin2);
SCLANG
  source: "https://github.com/philthomson/imp",
)

SINTH = SynthDef.new(name: "sinth", params: { :out => 0, :curve => 0, :dur => 1, :freq => 400, :level => 0.1 },
  body: <<-SCLANG,
  var env         = Env.perc(releaseTime: dur, level: level, curve: curve);
  var envgen        = EnvGen.kr(env, doneAction: 2);
  var sin         = SinOsc.ar([freq, freq + 0.1], mul: envgen);
  var sin2        = SinOsc.ar([freq, freq + 0.1] * 2.01, mul: envgen / 8);
  var sin3        = SinOsc.ar([freq, freq * 0.1] * 20.1, mul: envgen / 32);
  Out.ar(out, sin + sin2 + sin3);
SCLANG
  source: "https://github.com/philthomson/imp",
)

AEOLIAN_STRINGS = SynthDef.new(name: "aeolian_strings", params: { :out => 0 },
  body: <<-SCLANG,
  // aeolian strings
  var sig = Mix.fill(9,{i=Dust.ar(0.4)!2;CombC.ar(i,1,Select.ar(TIRand.kr(0,7,i),(55+Scale.aeolian.degrees).collect{|x|DC.ar(1/x.midicps)}),3)});
  Out.ar(out,sig);
SCLANG
  source: "https://github.com/thormagnusson/sctweets",
)

BONFIRE_NIGHT = SynthDef.new(name: "bonfire_night", params: { :out => 0 },
  body: <<-SCLANG,
  // the sound of new years eve in frosty Reykjavik
  var x=Decay;
  var d=Dust.ar(4);
  var sig = FreeVerb.ar(LPF.ar(x.ar(d,0.5,WhiteNoise.ar),2000)+x.ar(d,0.15,SinOsc.ar([40,47],pi,5)), 0.4,0.6,TRand.ar(0,1,d));
  Out.ar(out, sig);
SCLANG
  source: "https://github.com/thormagnusson/sctweets",
)

THAT_CLUB = SynthDef.new(name: "thatclub", params: { :out => 0 },
  body: <<-SCLANG,
  // the nightclub downstairs
  var x =SinOsc;
  var y =LFNoise0;
  var a = y.ar(8);
  var sig = x.ar(Pulse.ar(1)*24)+x.ar(90+(a*90))+MoogFF.ar(Saw.ar(y.ar(4,333,666)),a*XLine.ar(1,39,99,99,0,2));
  Out.ar(out, sig!2/3);
SCLANG
  source: "https://github.com/thormagnusson/sctweets",
)

DRUNK_DRUMMER = SynthDef.new(name: "drunk_drummer", params: { :out => 0 },
  body: <<-SCLANG,
  var i=Dust.ar(4), a=0.5, b=5e-3, q=Decay2, p=PulseDivider, n=WhiteNoise.ar;
  var sig = (SinOsc.ar(80)*q.ar(p.ar(i,2),a,b)+(n*q.ar(p.ar(i,4),b,a)));
  Out.ar(out,sig!2);
SCLANG
  source: "https://github.com/thormagnusson/sctweets",
)

EIGHTBIT_FUNK = SynthDef.new(name: "eightbit_funk", params: { :out => 0 },
  body: <<-SCLANG,
  // 8-bit funk
  var o=LFSaw.ar(LFSaw.kr(0.0005,-1).range(0.5,1)).abs*40;
  var sig = (o*15&(o>>5))|(o*100&(o>>1)&(o<<2))|(o*1e3&(o>>[1,2])&(LFSaw.kr(0.01).abs*5).ceil);
  Out.ar(out,sig!2);
SCLANG
  source: "https://github.com/thormagnusson/sctweets",
)

TWO_TIMPANIS = SynthDef.new(name: "two_timpanis", params: { :out => 0 },
  body: <<-SCLANG,
  var x=LFNoise0.ar(1)>0;
  var sig = SinOsc.ar(Spring.ar(x,4,3e-05)*(70.rand+190)+(30.rand+90))*EnvGen.kr(Env.perc(0.001,5),x);
  Out.ar(out, sig!2);
SCLANG
  source: "https://github.com/thormagnusson/sctweets",
)

TWO_TIMPANIS2 = SynthDef.new(name: "two_timpanis2", params: { :out => 0 },
  body: <<-SCLANG,
  var x=LFNoise0.ar(1)>0;
  var sig = SinOsc.ar(Spring.ar(x,4,3e-05)*(70.rand+190)+LFNoise2.ar(1).range(90,120))*EnvGen.kr(Env.perc(0.001,5),x);
  Out.ar(out, sig!2);
SCLANG
  source: "https://github.com/thormagnusson/sctweets",
)


# (
#   x = Signal.sineFill(513, [0.5, 0.2, 0.3, 0.0, 0.2]);
#   // x.plot;
#   b = Buffer.alloc(s, 1024, 1);
# );

# b.sendCollection(x.asWavetableNoWrap);

# SynthDef.new(name: "kick909", params: { :out => 0, :startPitch => 100, :lpf1 => 100, :lpf2 => 200, :lpf3 => 200, :gate => 1 },
#   body: <<-SCLANG,
#   var sig1, adsr1;
#   var sig2, sig3, adsr2, adsr3, mixed;

#   adsr1 = Env.adsr(0, 1, 0, 0.1, curve: -4);
#   adsr2 = Env.adsr(0, 0.1, 0, 0.1, curve: -8);
#   adsr3 = Env.adsr(0, 0.1, 0, 0.1);

#   sig1 = Saw.ar(XLine.ar(startPitch, 1, 8, doneAction: 2));
#   sig1 = Shaper.ar(b.bufnum, sig1);
#   sig1 = sig1 * EnvGen.kr(adsr1, gate: gate, doneAction: 2);
#   sig1 = LPF.ar(sig1, lpf1);

#   sig2 = LFPulse.ar(50, 0.1, 0.2) * EnvGen.kr(adsr2, gate: gate, doneAction: 2);
#   sig2 = LPF.ar(sig2, lpf2);

#   sig3 = WhiteNoise.ar(0.5) * EnvGen.kr(adsr3, gate: gate, doneAction: 2);
#   sig3 = LPF.ar(sig3, lpf3);

#   Out.ar(out, Mix.new([sig1, sig2, sig3]) ! 2);
# SCLANG
#   source: "https://github.com/mattvears/supercollider-stuff",
# )

HOOVER = SynthDef.new(name: "hoover", params: { :freq => 220, :amp => 0.1, :lgu => 0.1, :lgd => 1, :gate => 1 },
  body: <<-SCLANG,
var pwm, mix, env;

freq = freq.cpsmidi.lag(lgu,lgd).midicps;
freq = SinOsc.kr( { 2.9 rrand: 3.1 }!3, {2pi.rand}!3 ).exprange( 0.995, 1.005 ) * freq;
pwm = SinOsc.kr( {2.0 rrand: 4.0}!3 ).range(0.125,0.875);

// the saw/pulses
mix = (LFSaw.ar( freq * [0.25,0.5,1], 1 ).range(0,1)
    * (1 - LFPulse.ar(freq * [0.5,1,2], 0, pwm))).sum * 0.1;

// the bass
mix = mix + LFPar.ar( freq * 0.25, 0, 0.1 );

// eq for extra sharpness
mix = BPeakEQ.ar( mix, 6000, 1, 3 );
mix = BPeakEQ.ar( mix, 3500, 1, 6 );

// kind of chorus
mix = mix + CombC.ar( mix.dup, 1/200,
      SinOsc.kr( 3, [0.5pi, 1.5pi] ).range(1/300,1/200),
    0.0 ) * 0.5;

env = EnvGen.kr( Env.asr, gate );

Out.ar( 0, mix * env * amp );
SCLANG
  source: "https://github.com/rukano/scprivatepool",
)

SAWPULSE = SynthDef.new(name: "sawpulse", params: { :out => 0, :freq => 440, :gate => 0.5, :plfofreq => 6, :mw => 0, :ffreq => 2000, :rq => 0.3, :freqlag => 0.05, :amp => 1 },
  body: <<-SCLANG,
    var sig, plfo, fcurve;
    plfo = SinOsc.kr(plfofreq, mul:mw, add:1);
    freq = Lag.kr(freq, freqlag * 8) * plfo * 0.25;
    fcurve = EnvGen.kr(Env.adsr(0.1, 0.1, 0.4, 0.2), gate);
    fcurve = (fcurve - 1).madd(0.7, 1) * ffreq;
    sig = VarSaw.ar(freq*[1.001,3/2,1/2.001,1/4,1/2,3.001/2,1], width: LFNoise2.ar(0.3,0));
    //sig = BPF.ar(sig, fcurve, 0.2);
    //    * EnvGen.kr(Env.adsr(0.01, 0.2, 0.8, 1), gate, doneAction:2)
    //    * amp * 3;
    sig = sig * EnvGen.kr(Env.adsr(0.01, 0.2, 0.8, 1), gate, doneAction:2);
    Out.ar(out, Splay.ar(sig * 0.2, 1));
SCLANG
  source: "https://github.com/bwestergard/supercollider-experiments",
)

SAWPULSE2 = SynthDef.new(name: "sawpulse2", params: { :out => 0, :freq => 440, :gate => 0.5, :plfofreq => 6, :mw => 0, :ffreq => 2000, :rq => 0.3, :freqlag => 0.05, :amp => 1 },
  body: <<-SCLANG,
    var sig, plfo, fcurve;
    plfo = SinOsc.kr(plfofreq, mul:mw, add:1);
    freq = Lag.kr(freq, freqlag * 8) * plfo * 0.25;
    fcurve = EnvGen.kr(Env.adsr(0.1, 0.1, 0.4, 0.2), gate);
    fcurve = (fcurve - 1).madd(0.7, 1) * ffreq;
    sig = LFPulse.ar(freq*[1.001,3/2,1/2.001,1/4,1/2,3.001/2,1]*2, width: LFNoise2.ar(1/2).exprange(0.5,0.4));
    //sig = LPF.ar(sig, fcurve, 0.2) * 3;
    sig = sig * EnvGen.kr(Env.adsr(1, 0.2, 0.8, 0.3), gate, doneAction:2);
    Out.ar(out, Splay.ar(sig * 0.1, 1));
SCLANG
  source: "https://github.com/bwestergard/supercollider-experiments",
)

SINEPLUCK = SynthDef.new(name: "sinepluck", params: { :out => 0, :freq => 440, :amp => 1, :dur => nil },
  body: <<-SCLANG,
  var mod,tone;
  amp = amp * 0.8;
  dur =1/6;
  mod = VarSaw.ar(freq*2, mul: XLine.ar(0.2,0.8,dur/2), width: XLine.ar(1,1/1000,dur*64));
  tone = SinOsc.ar(freq, mod).dup * 0.1 * XLine.ar(1,1/1000,dur*4, doneAction:2) * XLine.ar(1/1000,1,0.001) * amp;
  tone = [DelayC.ar(tone , 1, LFNoise2.ar(1/2).range(0,0.012)), DelayC.ar(tone , 1, LFNoise2.ar(1/2).range(0.012,0))];
  tone = tone * XLine.ar(1/10000,1,0.005);
  Out.ar(out,tone);
SCLANG
  source: "https://github.com/bwestergard/supercollider-experiments",
)

POLY1 = SynthDef.new(name: "poly1", params: { :out => 0, :gate => 1, :freq => 440 },
  body: <<-SCLANG,
  var aEnv,fEnv,osc1, osc2,flt;
  aEnv=EnvGen.kr(Env.asr(0.2,1,0.1), gate, doneAction:2);
  fEnv=EnvGen.kr(Env.asr(7,1,0.2), levelScale:12000);
  osc1=Pulse.ar(freq*[1,1007], LFCub.kr(2,0,0.3,0.5));
  osc2= Pulse.ar(freq/2,0.3);
  flt=RLPF.ar(osc1+osc2, fEnv,0.9, aEnv);
  Out.ar(out, flt);
SCLANG
  source: "https://github.com/k-o-l-e-k-t-i-v/supercollider",
)

end
end
end
