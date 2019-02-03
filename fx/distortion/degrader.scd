(
synth: {arg sig_in;
	// original by Nathan Ho on supercollider slack

	var in = sig_in * \input.kr(1);
	var lfo = \lfo.kr(5);
	var ratelo = \ratelo.kr(1000);
	var ratehi = \ratehi.kr(16000);
	var sig = Latch.ar(in, Impulse.ar(LFNoise0.kr(lfo).lag(0.1).exprange(ratelo, ratehi)));
	Splay.ar(LeakDC.ar(sig), spread:\spread.kr(1), center:\center.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\lfo -> [(1/128), 20, \lin, 0.0, 5],
	\ratelo -> [1, 2000, \lin, 0.0, 1000],
	\ratehi -> [2000, 20000, \lin, 0.0, 16000],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0],
]
)