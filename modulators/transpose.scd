(
synth: {

	var freq = \freq.kr;
	var trans = \trans.kr;
	var note = freq.cpsmidi;
	(note + trans).midicps;

},
specs: [
	\freq -> \set,
	\trans -> [-24, 24, \lin, 1, 0]
]
)