(
func: {arg in;

	var sig = K2A.ar(in);
	LeakDC.ar(sig) * \vol.kr(0.dbamp);
},
specs: [
]
)