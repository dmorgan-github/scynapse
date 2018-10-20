(
func: {arg in;
	var sig = Squiz.ar(in,
		pitchratio: \pitchratio.kr(2),
		zcperchunk: \zcperchunk.kr(1)
	);
	Splay.ar(sig, spread:\spread.kr(1), center:\center.kr(0));
},
specs: (
	pitchratio: [1, 6, \lin, 0, 2],
	zcperchunk: [1, 100, \lin, 0, 1],
	spread: [0,1,\lin,0, 1],
	center: [-1,1,\lin,0,0]
)
)
