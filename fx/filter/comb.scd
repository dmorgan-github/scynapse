(
synth: {arg sig_in;
	var in = sig_in * \input.ar(1);
	var decay = \decay.ar(1);
	var delay = \delay.ar(0.2).lag(0.1);
	var sig = CombC.ar(in, 4, delay, decaytime:decay);
	Splay.ar(sig, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\decay -> [0.0, 10, \lin, 0.0, 1],
	\delay -> [0.0001, 4, \lin, 0, 0.2],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)