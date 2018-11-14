(
func: {arg in;
	var sig = Squiz.ar(in,
		pitchratio: \pitchratio.kr(12).midiratio,
		zcperchunk: \zcperchunk.kr(1)
	);
	LeakDC.ar(sig) * \vol.kr(0.dbamp);
},
specs: [
	\pitchratio -> [1, 24, \lin, 1, 12],
	\zcperchunk -> [1, 100, \lin, 0, 1]
]
)