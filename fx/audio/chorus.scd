(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);
	var sig = LADSPA.ar(1, 1201,
		\numvoices.kr(2), //\numvoices.kr.range(\numvoices_min.kr(1), \numvoices_max.kr(8)).lag(0.1),
		\delay.kr(10),
		\voicesep.kr(0),
		\detune.kr(0.1),
		\lfo.kr(2),
		\output.kr(0),
		in
	);

	Splay.ar(sig, spread:\spread.kr(1), center:\center.kr(0)) * \amp.kr(0.dbamp) * \vol.kr(0.dbamp);
},
specs: [
	\numvoices -> [1, 8, \lin, 1, 2],
	\delay -> [10, 40, \lin, 0, 10],
	\voicesep -> [0, 2, \lin, 0, 0],
	\detune -> [0, 5, \lin, 0, 0.1],
	\lfo -> [2, 30, \lin, 0, 2],
	\output -> [-20, 0, \lin, 0, 0],
	\amp -> [0,1,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)

