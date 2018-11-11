(
func: {arg in;

	var trig = \trig.kr;
	var atk = \atk.kr(0.01);
	var rel = \rel.kr(1);
	in * Decay2.kr(trig, atk, rel);
},
specs: [
	\trig -> \set,
	\atk -> [0, 1, \lin, 0, 0.01],
	\rel -> [0, 1, \lin, 0, 1]
]
)