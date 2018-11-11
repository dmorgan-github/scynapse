(
func: {arg in;

	var sig = DelayC.ar(in, 0.2, LFNoise2.kr([1, 1.1]).range(0, 0.005));
	Splay.ar(sig.flatten, spread:\spread.kr(1), center:\center.kr(0));
},
specs: [
	\spread -> [0, 1, \lin, 0, 1],
	\center -> [-1, 1, \lin, 0, 0]
]
)