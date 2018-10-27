(
func: {arg in;

	var sig = PitchShift.ar(in,
		0.5,
		\pitchRatio.kr(2).midiratio,
		\pitchDispersion.kr(0),
		\timeDispersion.kr(0)
	);
	sig
},
specs: [
	\pitchRatio -> [-24, 24, \lin, 0.0, 2],
	\pitchDispersion -> [0, 1, \lin, 0.0, 0.1],
	\timeDispersion -> [0.0, 0.1, \lin, 0, 0.1]
]
)