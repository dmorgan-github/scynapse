(
func: {arg in;

	var sig = CrossoverDistortion.ar(in,
		amp: \amp.kr(0.5),
		smooth: \smooth.kr(0.5)
	);

	LeakDC.ar(sig) * 0.1 * \vol.kr(0.dbamp);
},
specs: [
	\amp -> [0, 1, \lin, 0, 0.5],
	\smooth -> [0, 1, \lin, 0, 0.5]
]
)