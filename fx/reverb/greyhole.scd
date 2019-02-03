(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var sig = Greyhole.ar(in,
		\delayTime.kr(2),
		\damp.kr(0),
		\size.kr(1),
		\diff.kr(0.707),
		\feedback.kr(0.9),
		\modDepth.kr(0.1),
		\modFreq.kr(2)
	);

	Splay.ar(sig, spread:\spread.kr(1), center:\center.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\delayTime -> [0.1, 60, \lin, 0, 2],
	\damp -> [0, 1, \lin, 0, 0],
	\size -> [0.5, 5, \lin, 0, 1],
	\diff -> [0,1, \lin, 0, 0.707],
	\feedback -> [0,1, \lin,0, 0.9],
	\modDepth -> [0, 1, \lin, 0, 0.1],
	\modFreq -> [0, 10, \lin, 0, 2],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)