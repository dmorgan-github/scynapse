(
func: {arg in;

	var sig = Disintegrator.ar(in,
		probability:\prob.kr(0.5),
		multiplier:\mult.kr(0)
	);
	LeakDC.ar(sig) * \vol.kr(0.dbamp);
},
specs: [
	\prob -> [0, 1, \lin, 0, 0.5],
	\mult -> [-1, 1, \lin, 0, 0],
]
)