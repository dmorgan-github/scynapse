(
func: {arg in;

	var sig = PitchShift.ar(in,
		0.5,
		\pitchRatio.kr(12).midiratio,
		\pitchDispersion.kr(0.01),
		\timeDispersion.kr(0.01)
	);
	sig

},
specs: [
	\pitchRatio -> [-24, 24, \lin, 0.0, 12],
	\pitchDispersion -> [0, 1, \lin, 0.0, 0.01],
	\timeDispersion -> [0.0, 0.5, \lin, 0, 0.01]
]
)