(
func: {
	var atk = \atk.kr(1);
	var sus = \sus.kr(1);
	var rel = \rel.kr(1);
	var wait = \wait.kr(1);
	var curve = \curve.kr(-4);
	Env.circle([0,1,1,0],[atk,sus,rel,wait],curve).kr(gate:1);
},
specs: [
	\atk -> [0.001, 64, \lin, 0, 1],
	\sus -> [0.001, 64, \lin, 0, 1],
	\rel -> [0.001, 64, \lin, 0, 1],
	\wait -> [0.001, 64, \lin, 0, 1],
	\curve -> [-24, 24, \lin, 0, -4]
]
)
