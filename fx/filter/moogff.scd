(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var sig = MoogFF.ar(in, \freq.kr(100).clip(20, 20000), gain:\res.kr.linlin(0,1,0,4));
	Splay.ar(sig, spread:\spread.kr(1), center:\center.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\freq -> [20, 20000, \lin, 0, 1000],
	\res -> [0, 1, \lin, 0, 0],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)
