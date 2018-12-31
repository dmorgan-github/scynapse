(
// based on comment from Nathan Ho in Supercollider slack
synth: {
	var freq = \freq.kr;
	var smoothing = \smoothing.kr(0);
	TRand.ar(-1 , 1, Dust.ar(freq)).lag(smoothing)
},
specs: [
	\freq -> [1/512, 80, \lin, 0, 20],
	\smoothing -> [0, 1, \lin, 0, 0]
]
)