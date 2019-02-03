(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var sig = Decimator.ar(in,
		rate: 44100/\rate.kr(1).clip(1,10),
		bits: \bits.kr(24)
	);

	Splay.ar(LeakDC.ar(sig), spread:\spread.kr(1), center:\center.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\rate -> [1, 10, \lin, 0, 1],
	\bits -> [2, 24, \lin, 0, 24],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0],
]
)
