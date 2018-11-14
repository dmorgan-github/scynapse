(
func: {arg in;

	var trig = \trig.kr;
	var atk = \atk.kr(0.01);
	var sus = \sus.kr(1);
	var rel = \rel.kr(1);
	var curve = \curve.kr(-4);
	var ts = \ts.kr(1);
	in * Env.linen(atk, sus, rel, curve:curve).kr(gate:trig, timeScale:ts) * \vol.kr(0.dbamp);
},
specs: [
	\trig -> \set,
	\atk -> [0, 1, \lin, 0, 0.01],
	\sus -> [0, 1, \lin, 0, 1],
	\rel -> [0, 1, \lin, 0, 1],
	\curve -> [-24, 24, \lin, 0, -4],
	\ts -> [(1/64), 64, \lin, 0, 1]
]
)