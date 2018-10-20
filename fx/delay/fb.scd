(
func: {arg in;

	var fblevel = \fb.kr(0.3);
	var delL = \delL.kr(6).lag(0.1);
	var delR = \delR.kr(10).lag(0.1);
	var speed = \speed.kr(1).lag(0.1);
	var sig = FbC({arg fb; fb * fblevel + in}, [delL/16, delR/16] * speed);
	Splay.ar(sig, spread:\spread.kr(1), center:\center.kr(0));
},
specs: (
	fb: [0.0, 0.99, \lin, 0.0, 0.3],
	delL: [1, 16, \lin, 1, 6],
	delR: [1, 16, \lin, 1, 10],
	speed: [0.001, 16, \lin, 0.0, 1],
	spread: [0,1,\lin,0, 1],
	center: [-1,1,\lin,0,0]
)
)