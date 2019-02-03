(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var gain = \gain.kr(1);
	var sig = (in * gain).tanh * (gain.reciprocal.sqrt);
	//sig = DelayC.ar(sig, 0.1, Rand(3.5/1000, 65/1000));
	Splay.ar(LeakDC.ar(sig), spread:\spread.kr(1), center:\center.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\gain -> [1, 20, \lin, 0, 1],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)