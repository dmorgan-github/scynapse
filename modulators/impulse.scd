(
func: {
	var freq = \freq.kr;
	Impulse.kr(freq);
},
specs: [
	\freq -> [1/512, 80, \lin, 0, 20]
]
)