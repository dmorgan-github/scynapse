/*
(
GVerb.ar(
	in: a*LFNoise1.ar(40),
	roomsize: 400,
	revtime: 400,
	damping: 0.2,
	inputbw: 0.5,
	spread: 50,
	drylevel: 0,
	earlyreflevel: 0.2,
	taillevel: 0.9,
	maxroomsize: 400)
)
*/
(
func: {arg in;

	var sig = GVerb.ar(
		Mix.ar(in),
		50, // not modulatable
		\revtime.kr(3),
		\damping.kr(0.9),
		\inputbw.kr(0.75),
		\spread.kr(50),
		/*drylevel:*/ 0,
		\earlyreflevel.kr(0.07943282347242),
		\taillevel.kr(0.5)
	);

	sig;
},
specs: [
	\revtime -> [0.1, 1000, \lin, 0, 3],
	\damping -> [0, 1, \lin, 0, 0.9],
	\inputbw -> [0, 1, \lin, 0, 0.75],
	\spread -> [0, 100, \lin, 0, 50],
	\earlyreflevel -> [0.1, 1, \lin, 0, 0.07943282347242],
	\taillevel -> [0.1, 1, \lin, 0, 0.5],
]
)

