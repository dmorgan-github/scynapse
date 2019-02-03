(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var sig = CrossoverDistortion.ar(in,
		amp: \cossover.kr(0.5),
		smooth: \smooth.kr(0.5)
	);

	Splay.ar(LeakDC.ar(sig) * 0.1, spread:\spread.kr(1), center:\center.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\cossover -> [0, 1, \lin, 0, 0.5],
	\smooth -> [0, 1, \lin, 0, 0.5],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0],
]
)