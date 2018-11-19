(
synth: {

	var div = \div.kr;
	var trig = \trig.tr;
	PulseDivider.kr(trig, div);
},
specs: [
	\trig -> \set,
	\div -> [1, 16,\lin, 1, 1]
]
)