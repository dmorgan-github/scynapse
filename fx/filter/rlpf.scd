(
func: {arg in;

	var sig = RLPF.ar(in,
		\freq.kr(1000).clip(20, 20000),
		\rq.kr(1)
	);

	sig * \vol.kr(0.dbamp);
},
specs: [
	\freq -> [20, 20000, \lin, 0, 1000],
	\rq -> [0.001, 1, \lin, 0, 1]
]
)