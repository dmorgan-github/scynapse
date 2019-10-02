(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = DelayC.ar(in, 0.2, LFNoise2.ar([1, 1.1]).range(0, 0.005));
	Splay.ar(sig.flatten, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\spread -> [0, 1, \lin, 0, 1],
	\center -> [-1, 1, \lin, 0, 0],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)