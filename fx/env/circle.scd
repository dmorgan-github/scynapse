(
func: {arg in;

	var atk = \atk.kr(0.01);
	var rel = \rel.kr(1);
	var wait = \wait.kr(1);
	var curve = \curve.kr(-4);
	var ts = \ts.kr(1);
	in * Env.circle([0,1,0],[atk,rel,wait], curve:curve).kr(gate:1, timeScale:ts) * \vol.kr(0.dbamp);
},
specs: [
	\atk -> [0, 64, \lin, 0, 0.01],
	\rel -> [0, 64, \lin, 0, 1],
	\wait -> [0, 64, \lin, 0, 1],
	\curve -> [-24, 24, \lin, 0, -4],
	\ts -> [(1/64), 64, \lin, 0, 1]
]
)