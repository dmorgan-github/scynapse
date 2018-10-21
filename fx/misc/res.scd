(
func: {arg in;

	var numFreqs = 6;

	var detune = \detune.kr(0);

	var freq_in = Vibrato.ar(K2A.ar(\freq.kr(432).varlag(\lag.kr(0.0))),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var ffreqs = (0..numFreqs-1).collect({arg i;
		(\f ++ i).asSymbol.kr(1);
	}) + detune;

	var amps = (0..numFreqs-1).collect({arg i;
		(\a ++ i).asSymbol.kr(1/numFreqs);
	});

	var rings = (0..numFreqs-1).collect({arg i;
		(\r ++ i).asSymbol.kr(1);
	});

	var sig = DynKlank.ar(`[ffreqs, amps, rings], in, freq_in);

	sig = sig * AmpCompA.kr(freq_in);

	Splay.ar(sig.asArray.sum, spread:\spread.kr(1), center:\center.kr(0));
},
specs: [
	\freq -> [20, 20000, \lin, 0.0, 432],
	\f0 -> [0.1, 12, \lin, 0, 1],
	\f1 -> [0.1, 12, \lin, 0, 1],
	\f2 -> [0.1, 12, \lin, 0, 1],
	\f3 -> [0.1, 12, \lin, 0, 1],
	\f4 -> [0.1, 12, \lin, 0, 1],
	\f5 -> [0.1, 12, \lin, 0, 1],
	\r0 -> [0, 1, \lin, 0, 1],
	\r1 -> [0, 1, \lin, 0, 1],
	\r2 -> [0, 1, \lin, 0, 1],
	\r3 -> [0, 1, \lin, 0, 1],
	\r4 -> [0, 1, \lin, 0, 1],
	\r5 -> [0, 1, \lin, 0, 1],
	\a0 -> [0, 1, \lin, 0, 1],
	\a1 -> [0, 1, \lin, 0, 1],
	\a2 -> [0, 1, \lin, 0, 1],
	\a3 -> [0, 1, \lin, 0, 1],
	\a4 -> [0, 1, \lin, 0, 1],
	\a5 -> [0, 1, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)