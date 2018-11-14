(
func: {arg in;

	var sig = Decimator.ar(in,
		rate: 44100/\rate.kr(1).clip(1,10),
		bits: \bits.kr(24)
	);

	LeakDC.ar(sig) * \vol.kr(0.dbamp);
},
specs: [
	\rate -> [1, 10, \lin, 0, 1],
	\bits -> [2, 24, \lin, 0, 24]
]
)
