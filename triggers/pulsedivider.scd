(
synth: {

	var div = \div.kr(2);
	var trig = \trig.tr;
	var start = \start.kr;
	var scale = \scale.kr(0.1);
	PulseDivider.kr(trig, div, start) * scale;
},
specs: [
	\trig -> \set,
	\div -> [1, 16,\lin, 1, 2],
	\start -> [-32,32,\lin, 1, 1],
	\scale -> [0,1,\lin,0,0.1]
]
)