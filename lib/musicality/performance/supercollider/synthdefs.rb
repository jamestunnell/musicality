module Musicality
module SuperCollider
module SynthDefs

VOLUME_CONTROL = SynthDef.new(name: "volume_control", params: { :in => nil, :out => nil, :control => nil },
  body: <<-SCLANG,
  var sig = In.ar([in,in+1]) * In.kr(control);
  Out.ar(out,sig);
SCLANG
  credit: "James Tunnell",
)
 
VOLUME_CHANGE = SynthDef.new(name: "volume_change", params: { :vol_bus => nil, :vol => nil, :dur => nil },
  body: "  Out.kr(vol_bus, Line.kr(In.kr(vol_bus), vol, dur));",
  credit: "James Tunnell",
)

KICK808 = SynthDef.new(name: "kick808", params: { :out => 0 },
  body: <<-SCLANG,
  var sig = LPF.ar(Ringz.ar(Impulse.ar(0), 60, 1), 500);
  var cmp = CompanderD.ar(sig, -20.dbamp, 1, 0.3, 0.003, 0.08);

  cmp = cmp * (10.dbamp);
  Out.ar(out, cmp.dup);
SCLANG
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014"
)

KICK2 = SynthDef.new(name: "kick2", params: { :out => 0 },
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

  Out.ar(out, sig.dup * 0.1);
SCLANG
  credit: "Reformatted for the Roundhouse Synth Design course from 08091500Acid309 by otophilia from SuperCollider/examples folder",
  source: "https://github.com/acarabott/roundhouse-synth-design-course-2014",
)

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

// 

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

EIGHTTOEIGHT_KICK = SynthDef.new(name: "eightoeightkick", params: { :out => 0, :freq => 440, :amp => 0.1, 
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

KICK3 = SynthDef.new(name: "kick3", params: { :out => 0, :punch => 1, :amp => 1 },
  body: <<-SCLANG,
  var freq = EnvGen.kr(Env([400, 66], [0.08], -3)),
  sig = Normalizer.ar(SinOsc.ar(freq, 0.5pi, punch).distort, 1) * amp
            * EnvGen.kr(Env([0, 1, 0.8, 0], [0.01, 0.1, 0.2]), doneAction: 2);
    Out.ar(out, sig ! 2);
SCLANG
  source: "From https://github.com/brunoruviaro/SynthDefs-for-Patterns",
)

RING_KICK = SynthDef.new(name: "ringkick", params: { :out => 0, :freq => 40, :decay => 0.25, :amp => 1 },
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

KIK = SynthDef.new(name: "kik", params: { :out => 0, :basefreq => 50, :ratio => 7, :sweeptime => 0.05, :preamp => 1, :amp => 1, :decay1 => 0.3, :decay1L => 0.8, :decay2 => 0.15 },
  body: <<-SCLANG,
    var fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp)),
        env = EnvGen.kr(Env([1, decay1L, 0], [decay1, decay2], -4), doneAction: 2),
        sig = SinOsc.ar(fcurve, 0.5pi, preamp).distort * env * amp;
    Out.ar(out, sig ! 2)
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

CLOSED_HAT = SynthDef.new(name: "closedhat", params: { :out => 0 },
  body: <<-SCLANG,
  var hatosc, hatenv, hatnoise, hatoutput;

  hatnoise = {LPF.ar(WhiteNoise.ar(1),8000)};

  hatosc = {HPF.ar(hatnoise,2400)};
  hatenv = {Line.ar(1, 0, 0.1)};

  hatoutput = (0.5 * hatosc * hatenv);

  Out.ar(out, Pan2.ar(hatoutput, 0));
SCLANG
  source: "https://github.com/willieavendano/SC-SynthDefs/blob/master/DrumMachines",
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

CYMBALIC_MCLD = SynthDef.new(name: "cymbalic_mcld", params: { :out => 0, :pan => 0, :amp => 0.1 },
  body: <<-SCLANG,
  var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack;

  locutoffenv = EnvGen.ar(Env.perc(0.5, 5)) * 20000 + 10;
  lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);

  hicutoffenv = 10001 - (EnvGen.ar(Env.perc(1, 3)) * 10000);
  hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv);
  hidriver = hidriver * EnvGen.ar(Env.perc(1, 2, 0.25));

  thwack = EnvGen.ar(Env.perc(0.001,0.001,1));

  // This bit will regenerate new freqs every time you evaluate the SynthDef!
  freqs  = {exprand(300, 20000)}.dup(100);

  res    = Ringz.ar(lodriver + hidriver + thwack, freqs).mean;

  Out.ar(out, Pan2.ar(((res * 1) + (lodriver * 2) + thwack) * amp, pan));
SCLANG
  credit: "Based on the example at http://www.mcld.co.uk/cymbalsynthesis/ published 2008 by Dan Stowell",
  source: "https://github.com/supercollider-quarks/SynthDefPool",
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

BOOP = SynthDef.new(name: "boop", params: { :out => 0, :dur => 1.0, :amp => 1.0, :freq => 440 },
  body: <<-SCLANG,
  var env, sig;
  env = EnvGen.ar(Env.new([1, 0.1, 0], [0.06, dur - 0.06]), doneAction: 2);
  sig = LFTri.ar([freq * 0.995, freq * 1.005], 0, env * amp);
  Out.ar(out, sig ! 2);
SCLANG
  source: "https://github.com/mtytel/supersongs/",
)

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


FM_TOM = SynthDef.new(name: "fmtom", params: { :out => 0, :freq => 200, :gate => 1, :vol => 0.5 },
  body: <<-SCLANG,
  var tom = PMOsc.ar(freq, 280, Line.kr(0.0, 12, 1), mul: EnvGen.ar(Env.adsr(0.003,0.2,0,0), gate, levelScale: 0.3, doneAction: 2));
  Out.ar(out, tom * vol ! 2);
SCLANG
  source: "https://github.com/mattvears/supercollider-stuff",
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

SNARE3 = SynthDef.new(name: "snare", params: { :amp => 1, :dur => 0.05, :out => 0 },
  body: <<-SCLANG,
dur = dur * 16;
Out.ar(out, amp * XLine.ar(2,1/1000,dur) * BPF.ar(PinkNoise.ar(0.8), XLine.ar(20000,1000,dur, doneAction:2), 0.8).dup);
SCLANG
  source: "https://github.com/bwestergard/supercollider-experiments",
)

KICK1 = SynthDef.new(name: "kick", params: { :out => 0, :amp => 1, :dur => 0.05 },
  body: <<-SCLANG,
var tone;
tone = SinOsc.ar(XLine.ar(800,2,dur*4, mul: 0.2, doneAction:2));
Out.ar(out, amp * tone.dup * XLine.ar(2,1/1000,dur*4));
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