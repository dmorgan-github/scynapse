(
synth: {arg in;
	var gain = \gain.kr(1);
	var sig = (in * gain) / (1 + abs(in)) * (gain.reciprocal.sqrt);
	LeakDC.ar(sig) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\gain -> [1, 20, \lin, 0, 1],
	\amp -> [0,1,\lin,0,1]
]
)