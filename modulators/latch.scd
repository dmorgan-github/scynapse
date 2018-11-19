(
synth: {

	var in = \in.kr;
	var trig = \trig.kr;
	Latch.kr(in, trig);
},
specs: [
	\in -> \set,
	\trig -> \set
]
)