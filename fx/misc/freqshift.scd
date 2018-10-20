(
func: {arg in;

	var freq = \freq.kr(3);
	var sig = FreqShift.ar(in, [freq.neg,freq]);
	Splay.ar(sig, spread:\spread.kr(1), center:\center.kr(0));
},
specs: (
	freq: [0.0, 8000, \lin, 0.0, 3],
	spread: [0,1,\lin,0, 1],
	center: [-1,1,\lin,0,0]
)
)