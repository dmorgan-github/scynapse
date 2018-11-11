(
func: {arg in;

	var trig = \trig.kr;
	var atk = \atk.kr(0.01);
	var rel = \rel.kr(1);
	var curve = \curve.kr(-4);
	var ts = \ts.kr(1);
	in * Env.perc(atk, rel, curve:curve).kr(gate:trig, timeScale:ts);
},
specs: [
	\trig -> \set,
	\atk -> [0, 1, \lin, 0, 0.01],
	\rel -> [0, 1, \lin, 0, 1],
	\curve -> [-24, 24, \lin, 0, -4],
	\ts -> [(1/64), 64, \lin, 0, 1]
]
)