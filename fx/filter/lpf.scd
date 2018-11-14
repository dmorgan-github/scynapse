(
func: {arg in;
	var sig =LPF.ar(in,
		\freq.kr(1000).clip(20, 20000);
	);
	sig * \vol.kr(0.dbamp);
},
specs: [
	\freq -> [20, 20000, \lin, 0, 1000]
]
)