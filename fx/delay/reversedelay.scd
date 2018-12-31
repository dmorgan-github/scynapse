(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var sig = LADSPA.ar(1, 1605,
		in,
		\delay.kr(1).lag(0.1),
		-70, // dry
		0, // wet
		\feedback.kr(0.5).lag(0.1),
		\crossfade.kr(20)
	);

	sig * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\delay -> [0, 5, \lin, 0, 1],
	\feedback -> [0, 1, \lin, 0, 0.5],
	\crossfade -> [0, 100, \lin, 0, 20],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)