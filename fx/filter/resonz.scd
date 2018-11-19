(
synth: {arg in;

	var sig = Resonz.ar(in, \freq.kr(1000).clip(20, 20000), \bwr.kr(0.2) );
	sig * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\freq -> [20, 20000, \lin, 0, 1000],
	\bwr -> [0.01, 1, \lin, 0, 0.2],
	\amp -> [0,1,\lin,0,1]
]
)