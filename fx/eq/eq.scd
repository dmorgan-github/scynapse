(
synth: {arg sig_in;
	var in = sig_in * \input.ar(1);
	var sig = BLowShelf.ar(in, \loshelf.kr(1200).lag(0.1), \loshelf_rs.kr(1).lag(0.1), \loshelf_db.kr(0).lag(0.1));
    sig = BPeakEQ.ar(sig, \lo.kr(1200).lag(0.1), \lo_rs.kr(1).lag(0.1), \lo_db.kr(0).lag(0.1));
	sig = BPeakEQ.ar(sig, \mid.kr(1200).lag(0.1), \mid_rs.kr(1).lag(0.1), \mid_db.kr(0).lag(0.1));
	sig = BPeakEQ.ar(sig, \hi.kr(1200).lag(0.1), \hi_rs.kr(1).lag(0.1), \hi_db.kr(0).lag(0.1));
	sig = BHiShelf.ar(sig, \hishelf.kr(1200).lag(0.1), \hishelf_rs.kr(1).lag(0.1), \hishelf_db.kr(0).lag(0.1));
	sig = RemoveBadValues.ar(sig);
	Splay.ar(sig, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [

	\loshelf -> [1,1000,\lin,0,100],
	\loshelf_rs -> [0,10,\lin,0,1],
	\loshelf_db -> [-60, 20,\lin, 0, 0],

	\lo -> [100,2000,\lin,0,250],
	\lo_rs -> [0,10,\lin,0,1],
	\lo_db -> [-60, 20,\lin, 0, 0],

	\mid -> [250,6000,\lin,0,1000],
	\mid_rs -> [0,10,\lin,0,1],
	\mid_db -> [-60, 20,\lin, 0, 0],

	\hi -> [1000,20000,\lin,0,3500],
	\hi_rs -> [0,10,\lin,0,1],
	\hi_db -> [-60, 20,\lin, 0, 0],

	\hishelf -> [1000,20000,\lin,0,6000],
	\hishelf_rs -> [0,10,\lin,0,1],
	\hishelf_db -> [-60, 20,\lin, 0, 0],

	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)