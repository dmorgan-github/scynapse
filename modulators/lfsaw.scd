(
synth: {
	var freq = \freq.ar(1);
	LFSaw.ar(freq);
},
specs: [
	\freq -> [1/1024, 80, \lin, 0, 1]
]
)