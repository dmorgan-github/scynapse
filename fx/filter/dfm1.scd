(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var sig = DFM1.ar(in,
		\freq.kr(1000).clip(20, 20000);,
		\res.kr(0.1),
		\inputgain.kr(1),
		\type.kr(0),
		\noiselevel.kr(0.0003)
	);

	Splay.ar(sig, spread:\spread.kr(1), center:\center.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\freq -> [20, 20000, \lin, 0, 1000],
	\res -> [0.01, 1, \lin, 0, 0.1],
	\inputgain -> [0.1, 2, \lin, 0, 1],
	\type -> [0, 1, \lin, 1, 0],
	\noiselevel -> [0.0001, 1, \lin, 0.0001, 0.0003],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)