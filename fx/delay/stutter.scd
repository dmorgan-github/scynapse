(
synth: {arg in;

	var holdperiod = \hold.kr;
	var multiplier = \multiplier.kr;
	var rate = \rate.kr;
	Stutter.ar(in, Impulse.ar(holdperiod.reciprocal), holdperiod / multiplier, rate) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\hold -> [0.01, 1.0, \lin, 0, 0.01],
	\multiplier -> [1, 20, \lin, 0, 1],
	\rate -> [0.1, 1, \lin, 0, 1],
	\amp -> [0,1,\lin,0,1]
]
)
