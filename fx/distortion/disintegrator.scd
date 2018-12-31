(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var sig = Disintegrator.ar(in,
		probability:\prob.kr(0.5),
		multiplier:\mult.kr(0)
	);
	LeakDC.ar(sig) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\prob -> [0, 1, \lin, 0, 0.5],
	\mult -> [-1, 1, \lin, 0, 0],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)