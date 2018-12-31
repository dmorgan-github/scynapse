(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	Pan2.ar(in, \pos.kr(0) ) * \vol.kr(0.dbamp);
},

specs: [
	\pos -> [-1, 1, \lin, 0, 0],
	\input -> [0, 10, \lin, 0, 1]
]
)