(
synth: {
	var freq = \freq.kr;
	LFSaw.kr(freq);
},
specs: [
	\freq -> [1/512, 80, \lin, 0, 1]
]
)