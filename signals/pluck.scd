(
view: {arg objName, envir, components;

	var node = NodeProxy.audio(s, 2).source_({
		var which = \which.kr(0);
		var focus = \focus.kr(1);
		var noise = SelectXFocus.kr(which,
			[BrownNoise.ar(1), PinkNoise.ar(1), WhiteNoise.ar(1)],
			focus,
			wrap:true);
		var trig = \trig.tr;
		var freq = Vibrato.kr(\freq.kr(432), \vrate.kr(6), \depth.kr(0.001));
		var sig = Pluck.ar(noise,
			trig:trig,
			maxdelaytime:100.reciprocal,
			delaytime:freq.reciprocal.lag(\lag.kr(0)),
			decaytime:\decay.kr(1),
			coef:\coef.kr(0.5)
		);

		sig = sig * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);
		Splay.ar(LeakDC.ar(sig), \spread.kr(1), center:\center.kr(0));
	});

	var specs = [
		\trig -> \set,
		\freq -> \set,
		\lag -> [0,1,\lin,0,0],
		\which -> [0, 2, \lin, 1, 0],
		\focus -> [0,1, \lin, 0, 1],
		\vrate -> [0,6, \lin,0,0.001],
		\vdepth -> [0,1, \lin, 0, 0.001],
		\decay -> [-24, 24, \lin, 0, 1],
		\coef -> [-1,1,\lin, 0, 0.5],
		\amp -> [0, 1, \lin, 0, 0.1],
		\spread -> [0, 1, \lin, 0, 1],
		\center -> [-1, 1, \lin, 0, 0]
	];

	var view = View().layout_(VLayout().spacing_(2).margins_(2));
	var playView = components[\playView].(objName, node, view);
	var specsView = components[\specsView].(objName, specs, node, envir, view);
	var eqView = components[\eqView].(objName, node, envir, view);

	envir[objName] = node;
	view.layout.add(playView);
	view.layout.add(eqView);
	view.layout.add(specsView);

	view;
}
)
