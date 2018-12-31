(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var sig = RLPF.ar(in,
		\freq.kr(1000).clip(20, 20000),
		\rq.kr(1)
	);

	sig * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\freq -> [20, 20000, \lin, 0, 1000],
	\rq -> [0.001, 1, \lin, 0, 1],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)