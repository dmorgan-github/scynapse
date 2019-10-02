(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var bw = \bw.ar(1);
	var sig = BBandPass.ar(in,
		\freq.ar(1200).clip(20, 20000),
		bw,
		mul:bw.reciprocal.sqrt
	);

	Splay.ar(sig, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\freq -> [20, 20000, \lin, 0, 1200],
	\bw -> [0, 10.0, \lin, 0, 1],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)
