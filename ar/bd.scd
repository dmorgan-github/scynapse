(
func: {
	var trig = \trig.tr;
	var freq = Env([444,444,33],[0, 0.1], -7).kr(gate:trig);
	var sig = SinOsc.ar(freq, 0.5pi).tanh
	+ (WhiteNoise.ar(0.1) * Decay2.kr(trig, attackTime:0.0001, decayTime:0.01))
	+ SinOsc.ar(61);
	var env = Env.perc(attackTime: 0.001, releaseTime: 0.2, curve: -4 ).kr(gate:trig);
	sig = sig * env * \amp.kr(0.1);
	Pan2.ar(sig, \pan.kr(0));
},
specs: (
	trig: \set
)
)
