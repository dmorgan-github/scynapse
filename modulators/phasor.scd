(
synth: {

	var trig = \trig.tr;
	var rate = \rate.kr(1);
	var start = \start.kr(-1);
	var end = \end.kr(1);
	var resetPos = \reset.kr(-1);
	Phasor.kr(trig: trig, rate: rate, start: start, end: end, resetPos: resetPos);
},
specs: [
	\trig -> \set,
	\rate -> [0.001, 20, \lin, 0, 1],
	\start -> [-1, 1, \lin, 0, -1],
	\end -> [-1, 1, \lin, 0, 1],
	\reset -> [-1, 1, \lin, 0, -1]
]
)
