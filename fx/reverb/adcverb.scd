AdCVerb.maxTime = 10;
(
func: {arg in;

	var sig = AdCVerb.ar(in,
		revTime:\revTime.kr(3),
		hfDamping:\hfDamping.kr(0.1),
		nOuts:2,
		predelay:\predelay.kr(0.02),
		numCombs:8,
		numAllpasses:4,
		inFilter:\inFilter.kr(0.6),
		combScale:\combScale.kr(1).lag(0.1),
		apScale:\apScale.kr(1).lag(0.1)
	);

	Splay.ar(sig, spread:\spread.kr(1), center:\center.kr(0));
},
specs: (
	revTime: [0.1, 60, \lin, 0.0, 3],
	hfDamping: [0, 1, \lin, 0.0, 0.1],
	predelay: [0, 30, \lin, 0, 0.02],
	inFilter: [0, 1, \lin, 0, 0.6],
	combScale: [0.1, 10, \lin, 0, 1],
	apScale: [0.1, 10, \lin, 0, 1]
)
)