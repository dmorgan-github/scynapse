(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var holdperiod = \hold.kr;
	var multiplier = \multiplier.kr;
	var rate = \rate.kr;
	var sig = Stutter.ar(in, Impulse.ar(holdperiod.reciprocal), holdperiod / multiplier, rate) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
	Splay.ar(sig, spread:\spread.kr(1), center:\center.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\hold -> [0.01, 1.0, \lin, 0, 0.01],
	\multiplier -> [1, 20, \lin, 0, 1],
	\rate -> [0.1, 1, \lin, 0, 1],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0],
]
)
