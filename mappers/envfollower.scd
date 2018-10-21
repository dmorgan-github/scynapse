(
func: {arg in;
	EnvFollow.kr(in.asArray.sum, decaycoeff:\decay.kr(0.99));
},
specs: [
	\decay -> [0.0, 0.99, \lin, 0.0, 0.99]
]
)
