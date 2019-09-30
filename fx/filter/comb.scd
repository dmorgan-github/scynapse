(
synth: {arg sig_in;
	var in = sig_in * \input.kr(1);
	var decay = \decay.kr(1);
	var delay = \delay.kr(0.2).lag(0.1);
	var sig = CombC.ar(in, 4, delay, decaytime:decay);
	Splay.ar(sig, spread:\spread.kr(1), center:\center.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\decay -> [0.0, 10, \lin, 0.0, 1],
	\delay -> [0.0001, 4, \lin, 0, 0.2],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)