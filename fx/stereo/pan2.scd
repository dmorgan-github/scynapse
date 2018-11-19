(
synth: {arg in;
	Pan2.ar(in, \pos.kr(0) ) * \vol.kr(0.dbamp);
},

specs: [
	\pos -> [-1, 1, \lin, 0, 0]
]
)