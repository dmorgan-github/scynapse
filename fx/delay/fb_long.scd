(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var fblevel = \fb.kr(0.7);
	var delL = \delL.kr(6).lag(0.1);
	var delR = \delR.kr(10).lag(0.1);
	var sig = FbC({arg fb; fb * fblevel + in}, 16, [delL, delR]);
	Splay.ar(sig, spread:\spread.kr(1), center:\center.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\fb -> [0.0, 0.99, \lin, 0.0, 0.7],
	\delL -> [1, 16, \lin, 1, 6],
	\delR -> [1, 16, \lin, 1, 10],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)