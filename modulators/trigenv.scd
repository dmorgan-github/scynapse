(
func: {

	var trig = \trig.tr;
	var rel = \rel.kr(1);
	var atk = \atk.kr(1);
	var curve = \curve.kr(-4);
	var ts = \ts.kr(1);
	Env([-1,1,-1], [atk,rel], curve:curve).kr(gate:trig, timeScale:ts);
},
specs: [
	\trig -> \set,
	\atk -> [0.001, 1, \lin, 0, 1],
	\rel -> [0.001, 1, \lin, 0, 1],
	\ts -> [0.001, 64, \lin, 0, 1],
	\curve -> [-24, 24, \lin, 0, -4]
]
)
