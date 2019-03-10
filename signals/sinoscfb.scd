(
view: {arg objName, envir, components;

	var numvoices = 2;
	var nodefunc = {arg numvoices = 2;

		{
			var detune = \detune.kr(0.01);
			var trig = \trig.tr;
			var freq = Vibrato.kr(
				\freq.kr(432).lag(\lag.kr(0.1)),
				\vrate.kr(6),
				\vdepth.kr(0.001)
			);
			var fb = \fb.kr(0.5);
			var sig = {
				SinOscFB.ar(freq * LFNoise2.kr(\ddepth.kr(5)).range(1 + detune.neg, 1 + detune),
					feedback:fb) * (1/numvoices)
			}.dup(numvoices) * Array.fill(numvoices,1).normalizeSum;

			var susLevel = \susLevel.kr(0.7);
			var curve = \curve.kr(-4);
			var env = Env(
				[0,1,susLevel,susLevel,0],
				[\atk.kr(0.01), \dec.kr(0.3), \sus.kr(1), \rel.kr(1)],
				curve:curve
			).kr(gate:trig, timeScale:\ts.kr(1));

			sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
			sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
			sig;
		};
	};

	var node = NodeProxy.audio(s, 2).source_(nodefunc.(numvoices));

	var specs = [
		\trig -> \set,
		\freq -> \set,
		\ddepth -> [(1/128), 20, \lin, 0, 5],
		\detune -> [0, 1, \lin, 0, 0.01],
		\fb -> [0, 1, \lin, 0, 0.5],
		\atk -> [0, 1, \lin, 0, 0.01],
		\dec -> [0, 1, \lin, 0, 0.3],
		\sus -> [0, 1, \lin, 0, 1],
		\susLevel -> [0,1,\lin,0,0.7],
		\rel -> [0, 1, \lin, 0, 1],
		\curve -> [-24, 24, \lin, 0, -4],
		\ts -> [0, 64, \lin, 0, 1],
		\lag -> [0, 1, \lin, 0, 0],
		\amp -> [0, 1, \lin, 0, 0.1],
		\spread -> [0, 1, \lin, 0, 1],
		\center -> [-1, 1, \lin, 0, 0]
	];

	var view = View().layout_(VLayout().spacing_(2).margins_(2));
	var playView = components[\playView].(objName, node, view);
	var specsView = components[\specsView].(objName, specs, node, envir, view);
	var eqView = components[\eqView].(objName, node, envir, view);
	var pulseView = View().layout_(HLayout(
		NumberBox().maxDecimals_(0).action_({arg ctrl;
			var num = ctrl.value;
			envir[objName][0] = nodefunc.(num);
		})
		.normalColor_(Color.white)
		.value_(numvoices)
	));

	envir[objName] = node;
	view.layout.add(playView);
	view.layout.add(eqView);
	view.layout.add(pulseView);
	view.layout.add(specsView);

	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
		}.defer(envir[objName].fadeTime + 1);
		NotificationCenter.notify(view, \close, objName);
	});
}
)
