(
func: {arg in;

	var sig = PitchShift.ar(in,
		0.5,
		\pitchRatio.kr(1).midiratio,
		\pitchDispersion.kr(0),
		\timeDispersion.kr(0)
	);

	Splay.ar(sig);
},
specs: [
	\pitchRatio -> [-24, 24, \lin, 0.0, 0],
	\pitchDispersion -> [0, 1, \lin, 0.0, 0.1],
	\timeDispersion -> [0.0, 0.1, \lin, 0, 0.1]
]
)