(
synth: {arg in;

	var sig = K2A.ar(in);
	LeakDC.ar(sig) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\amp -> [0,1,\lin,0,1]
]
)