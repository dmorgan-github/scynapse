(
synth: {arg in;
	var sig = Ringz.ar(in, \freq.kr(440).clip(20, 20000), \decaytime.kr(1) );
	sig * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\freq -> [20, 20000, \lin, 0, 440],
	\decaytime -> [0.01, 1, \lin, 0, 1],
	\amp -> [0,1,\lin,0,1]
]
)