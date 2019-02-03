(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var sig = Squiz.ar(in,
		pitchratio: \pitchratio.kr(12).midiratio,
		zcperchunk: \zcperchunk.kr(1)
	);
	Splay.ar(LeakDC.ar(sig), spread:\spread.kr(1), center:\center.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\pitchratio -> [1, 24, \lin, 1, 12],
	\zcperchunk -> [1, 100, \lin, 0, 1],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)