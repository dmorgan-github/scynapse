(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var sig = K2A.ar(in);
	LeakDC.ar(sig) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)