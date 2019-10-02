(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var atk = \atk.ar(0.01);
	var rel = \rel.ar(1);
	var wait = \wait.ar(1);
	var curve = \curve.ar(-4);
	var ts = \ts.ar(1);
	in * Env.circle([0,1,0],[atk,rel,wait], curve:curve).kr(gate:1, timeScale:ts) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\atk -> [0, 64, \lin, 0, 0.01],
	\rel -> [0, 64, \lin, 0, 1],
	\wait -> [0, 64, \lin, 0, 1],
	\curve -> [-24, 24, \lin, 0, -4],
	\ts -> [(1/64), 64, \lin, 0, 1],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)