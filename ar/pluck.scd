(
func: {

	var which = \which.kr(0);
	var focus = \focus.kr(1);
	var noise = SelectXFocus.kr(which,
		[BrownNoise.ar(1), PinkNoise.ar(1), WhiteNoise.ar(1)],
		focus,
		wrap:true);
	var trig = \trig.tr;
	var freq = Vibrato.kr(\freq.kr(432), \vrate.kr(6), \depth.kr(0.001));
	var sig = Pluck.ar(noise,
		trig:trig,
		maxdelaytime:100.reciprocal,
		delaytime:freq.reciprocal,
		decaytime:\decay.kr(1),
		coef:\coef.kr(0.5)
	);

	sig = sig * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);
	sig = Pan2.ar(LeakDC.ar(sig), \pan.kr(0));
	sig;
},
specs: [
	\trig -> \set,
	\freq -> \set,
	\which -> [0, 2, \lin, 1, 0],
	\focus -> [0,1, \lin, 0, 1],
	\vrate -> [0,6, \lin,0,0.001],
	\vdepth -> [0,1, \lin, 0, 0.001],
	\decay -> [-24, 24, \lin, 0, 1],
	\coef -> [-1,1,\lin, 0, 0.5],
	\amp -> [0, 1, \lin, 0, 0.1]
]
)
