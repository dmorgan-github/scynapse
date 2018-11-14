(
func: {arg in;
	var sig = WaveLoss.ar(in,
		\drop.kr(20),
		\outof.kr(40),
		\mode.kr(1),
	);
	LeakDC.ar(sig) * \vol.kr(0.dbamp);
},
specs: [
	\drop -> [1,50,\lin,1,20],
	\outof -> [1,100,\lin,1,40],
	\mode -> [1,2,\lin,1,1],
]
)