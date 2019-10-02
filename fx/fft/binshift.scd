(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var stretch = \stretch.ar(1).range(\stretch_min.ar(0.01), \stretch_max.ar(8));
	var shift = \shift.ar(0).range(\shift_min.ar(0.01), \shift_max.ar(8));
	var chain = FFT( { LocalBuf(512) } ! 2, in);
	chain = PV_BinShift(chain, stretch, shift, interp: 1);
	chain = IFFT(chain);
	Splay.ar(chain, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\stretch -> [0.01, 8, \lin, 0, 1],
	\shift -> [0.01, 8, \lin, 0, 0],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)