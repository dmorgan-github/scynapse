(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = Ringz.ar(in, \freq.ar(440).clip(20, 20000), \decaytime.ar(1) );
	Splay.ar(sig, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\freq -> [20, 20000, \lin, 0, 440],
	\decaytime -> [0.01, 1, \lin, 0, 1],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)