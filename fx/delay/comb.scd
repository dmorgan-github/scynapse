(
synth: {arg in;

	var decay = \decay.kr(1);
	var delL = \delL.kr(6).lag(0.1);// * 16.reciprocal;
	var delR = \delR.kr(10).lag(0.1);// * 16.reciprocal;
	var tempo = \tempo.kr(1).lag(0.1);
	var speed = \speed.kr(0).lag(0.1);
	var sig = CombC.ar(in, 4, [delL, delR] * tempo + speed, decaytime:decay);
	Splay.ar(sig, spread:\spread.kr(1), center:\center.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\decay -> [0.0, 10, \lin, 0.0, 1],
	\delL -> [0.0001, 4, \lin, 0, 0.2],
	\delR -> [0.0001, 4, \lin, 0, 0.2],
	\tempo -> [0.001, 4, \lin, 0.0, 1],
	\speed -> [0.001, 4, \lin, 0.0, 0],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0],
	\amp -> [0,1,\lin,0,1]
]
)