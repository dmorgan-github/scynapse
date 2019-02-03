(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var sig = LADSPA.ar(1, 1217,
		\rate.kr(1),
		\depth.kr(0.5),
		\feedback.kr(0),
		\spread.kr(0.1),
		in
	);

	Splay.ar(sig, spread:\splay.kr(1), center:\center.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\rate -> [0, 100, \lin, 0, 1],
	\depth -> [0, 1, \lin, 0, 0.5],
	\feedback -> [-1, 1, \lin, 0, 0],
	\spread -> [0, 2, \lin, 0, 0.1],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\splay -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)