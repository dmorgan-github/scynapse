(
synth: {
	var freq = \freq.ar(20);
	LFDNoise3.ar(freq);
},
specs: [
	\freq -> [1/1024, 80, \lin, 0, 20]
]
)