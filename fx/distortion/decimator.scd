(
func: {arg in;

	var sig = Decimator.ar(in,
		rate: 44100/\rate.kr(1).clip(1,10)
		bits: \bits.kr(24)
	);

	//SmoothDecimator.ar(input, samplerate, smoothing);

	LeakDC.ar(sig);
},
specs: (
	rate: [1, 10, \lin, 0, 1],
	bits: [2, 24, \lin, 0, 24]
)
)
