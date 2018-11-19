(
synth: {arg in;

	var sig = CrossoverDistortion.ar(in,
		amp: \cossover.kr(0.5),
		smooth: \smooth.kr(0.5)
	);

	LeakDC.ar(sig) * 0.1 * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\cossover -> [0, 1, \lin, 0, 0.5],
	\smooth -> [0, 1, \lin, 0, 0.5],
	\amp -> [0,1,\lin,0,1]
]
)