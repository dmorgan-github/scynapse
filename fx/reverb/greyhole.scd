(
synth: {arg in;
	var sig = Greyhole.ar(in,
		\delayTime.kr(2),
		\damp.kr(0),
		\size.kr(1),
		\diff.kr(0.707),
		\feedback.kr(0.9),
		\modDepth.kr(0.1),
		\modFreq.kr(2)
	);

	sig * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\delayTime -> [0.1, 60, \lin, 0, 2],
	\damp -> [0, 1, \lin, 0, 0],
	\size -> [0.5, 5, \lin, 0, 1],
	\diff -> [0,1, \lin, 0, 0.707],
	\feedback -> [0,1, \lin,0, 0.9],
	\modDepth -> [0, 1, \lin, 0, 0.1],
	\modFreq -> [0, 10, \lin, 0, 2],
	\amp -> [0,1,\lin,0,1]
]
)