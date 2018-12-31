(
synth: {arg sig_in;
	var in = sig_in * \input.kr(1);
	EnvFollow.ar(in.asArray.sum, decaycoeff:\decay.kr(0.99));
},
specs: [
	\decay -> [0.0, 0.99, \lin, 0.0, 0.99]
]
)
