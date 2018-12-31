(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	Splay.ar(in,
		\spread.kr.range(\spread_min.kr(0), \spread_max.kr(1)),
		1,
		\center.kr(0)
	) * \vol.kr(0.dbamp);
},

specs: [
	\spread -> [0, 1, \lin, 0, 1],
	\center -> [-1, 1, \lin, 0, 0],
	\input -> [0, 10, \lin, 0, 1]
]
)