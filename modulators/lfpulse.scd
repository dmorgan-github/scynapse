(
synth: {
	var freq = \freq.ar;
	var width = \width.ar;
	LFPulse.ar(freq, width:width);
},
specs: [
	\freq -> [1/1024, 80, \lin, 0, 1],
	\width -> [0, 1, \lin, 0, 0.5]
]
)