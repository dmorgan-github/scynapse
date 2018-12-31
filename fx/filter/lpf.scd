(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var sig =LPF.ar(in,
		\freq.kr(1000).clip(20, 20000);
	);
	sig * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\freq -> [20, 20000, \lin, 0, 1000],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)