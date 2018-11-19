(
synth: {arg in;
	Balance2.ar(in[0], in[1], \pos.kr(0) ) * \vol.kr(0.dbamp);
},

specs: [
	\pos -> [-1, 1, \lin, 0, 0]
]
)