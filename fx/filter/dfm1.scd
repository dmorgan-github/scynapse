(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = DFM1.ar(in,
		\freq.ar(1000).clip(20, 20000);,
		\res.ar(0.1),
		\inputgain.ar(1),
		\type.ar(0),
		\noiselevel.ar(0.0003)
	);

	Splay.ar(sig, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\freq -> [20, 20000, \lin, 0, 1000],
	\res -> [0.01, 1, \lin, 0, 0.1],
	\inputgain -> [0.1, 2, \lin, 0, 1],
	\type -> [0, 1, \lin, 1, 0],
	\noiselevel -> [0.0001, 1, \lin, 0.0001, 0.0003],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)