(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var sig = PitchShift.ar(in,
		0.5,
		\pitchRatio.kr(12).midiratio,
		\pitchDispersion.kr(0.01),
		\timeDispersion.kr(0.01)
	);

	Splay.ar(sig, spread:\spread.kr(1), center:\center.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\pitchRatio -> [-24, 24, \lin, 1, 12],
	\pitchDispersion -> [0, 1, \lin, 0.0, 0.01],
	\timeDispersion -> [0.0, 0.5, \lin, 0, 0.01],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)