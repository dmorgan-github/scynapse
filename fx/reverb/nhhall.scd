(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);

	var sig = NHHall.ar(in,
		\rt60.kr(1).lag(0.1),
		\stereo.kr(0.5),
		\lowFreq.kr(200),
		\lowRatio.kr(0.5),
		\hiFreq.kr(4000),
		\hiRatio.kr(0.5),
		\earlyDiffusion.kr(0.5),
		\lateDiffusion.kr(0.5),
		\modRate.kr(0.2),
		\modDepth.kr(0.3)
	);

	Splay.ar(sig, spread:\spread.kr(1), center:\center.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\rt60 -> [0.1, 60, \lin, 0.0, 1],
	\stereo -> [0, 1, \lin, 0, 0.5],
	\lowFreq -> [20, 20000, \exp, 0, 200],
	\lowRatio -> [0, 1, \lin, 0, 0.5],
	\hiFreq -> [20, 20000, \exp, 0, 40000],
	\hiRatio -> [0, 1, \lin, 0, 0.5],
	\earlyDiffusion -> [0, 1, \lin, 0, 0.5],
	\lateDiffusion -> [0, 1, \lin, 0, 0.5],
	\modRate -> [0, 1, \lin, 0, 0.2],
	\modDepth -> [0,1,\lin, 0, 0.3],
	\spread -> [0, 1, \lin, 0, 1],
	\center -> [-1, 1, \lin, 0, 0],
	\amp -> [0,1,\lin, 0, 1],
	\input -> [0, 10, \lin, 0, 1]
]
)