(
synth: {

	var sig1 = \sig1.kr;
	var sig2 = \sig2.kr;
	(sig1 + sig2).range(-1,1);
},
specs: [
	\sig1 -> \set,
	\sig2 -> \set
]
)