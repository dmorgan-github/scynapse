(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var bw = \bw.kr(1);
	var sig = BBandPass.ar(in,
		\freq.kr(1200).clip(20, 20000),
		bw,
		mul:bw.reciprocal.sqrt
	);

	sig * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\freq -> [20, 20000, \lin, 0, 1200],
	\bw -> [0, 10.0, \lin, 0, 1],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)
