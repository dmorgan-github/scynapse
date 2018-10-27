(
func: {arg in;
	var sig = Squiz.ar(in,
		pitchratio: \pitchratio.kr(2),
		zcperchunk: \zcperchunk.kr(1)
	);
	LeakDC.ar(sig);
},
specs: [
	\pitchratio -> [1, 6, \lin, 0, 2],
	\zcperchunk -> [1, 100, \lin, 0, 1]
]
)
