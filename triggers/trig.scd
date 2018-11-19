(
synth: {

	var sig = \sig.kr;
	var dur = \dur.kr;
	Trig1.kr(sig, dur) * \level.kr(0.dbamp);

},
specs: [
	\sig -> \set,
	\dur -> [0, 1, \lin, 0, 0.01],
	\level -> [0,1,\lin,0,1]
]
)